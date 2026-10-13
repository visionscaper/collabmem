"""
Tests of the session hook, run as a script.

The hook is a shell script. Each test sets up a project folder and a home
folder in a temporary place, runs the script the way Claude Code does (the
event as JSON on standard input, the project as working directory), and
looks at what it printed and at what it wrote in the personal file.

No model is needed, and nothing outside the temporary folders is touched.

Run from the repository root:

    python3 -m unittest discover -s tests/clients/claude_code -v
"""

from typing import Dict, Optional

import json
import os
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path


REPOSITORY_ROOT = Path(__file__).resolve().parents[3]
HOOK = REPOSITORY_ROOT / "clients" / "claude-code" / "hooks" / "collab-memory-hook.sh"

BASH = shutil.which("bash")

# The version the test projects have installed, unless a test says otherwise.
VERSION = "1.8.7"
PREVIOUS_VERSION = "1.8.6"

# Texts of the hook that the tests look for. Each is a part of one message
# that appears in no other message.
WELCOME = "welcome to collabmem, and thanks for using it!"
UPGRADE_MESSAGE = "collabmem was upgraded to version"
SIGNAL_QUESTION = "One quick question from the collabmem developers"
FULL_MESSAGE = "the full message"
SHORT_ASK = "the short ask"
PENDING_QUESTIONS = "Questions from the collabmem developers are pending"
STAR_FIRST_ASK = "the star ask (the first ask)"
STAR_FOLLOW_UP_ASK = "the star ask (the follow-up ask)"
STAR_ASK = "the star ask"
INSTALL_SIGNAL = "the install signal"
PERSONAL_FILE_PROBLEM = "PROBLEM WITH THE PERSONAL COLLABMEM FILE"
DEVELOPERS = "collabmem developers"
LOAD_CHECK = "COLLABMEM-LOAD-CHECK"

# What the hook needs besides git. Used to build a machine without git.
TOOLS_OF_THE_HOOK = (
    "cat", "tr", "grep", "head", "sed", "cut", "date", "dirname", "mkdir",
)


def make_project(
    parent: Path,
    name: str = "project",
    version: Optional[str] = VERSION,
    entries: int = 0,
    install_id: bool = True,
) -> Path:
    """
    Makes a project folder with collabmem installed in it.

    :param parent: The folder the project is made in.
    :param name: The name of the project folder.
    :param version: The installed collabmem version, without the "v". With
        None the version marker is left out.
    :param entries: The number of entries in the episodic index.
    :param install_id: Whether the project has an install ID.

    :return: The project folder.
    """
    project = parent / name
    collab = project / "collab"
    (collab / "world").mkdir(parents=True)

    (project / ".collab-config").write_text("collab_dir=collab\n")

    for memory_file in (
        "methodology.md",
        "notes.md",
        "world/index.md",
        "world/context.md",
        "world/preferences.md",
        "world/state.md",
    ):
        (collab / memory_file).write_text("")

    if version is not None:
        set_installed_version(project, version)

    set_index_entries(project, entries)

    if install_id:
        (collab / ".install-id").write_text("0f8a1c2e-test\n")

    return project


def set_installed_version(project: Path, version: str) -> None:
    (project / "collab" / ".collab-memory-system").write_text(f"v{version}\n")


def set_index_entries(project: Path, entries: int) -> None:
    lines = [
        "| Date | Who | Title | Summary | Keywords |",
        "|------|-----|-------|---------|----------|",
    ]
    lines += [
        f"| 01-10-2026 | @sam | Note {number} | A summary | a-keyword |"
        for number in range(entries)
    ]

    (project / "collab" / "index.md").write_text("\n".join(lines) + "\n")


def personal_file(home: Path) -> Path:
    return home / ".config" / "collabmem" / "personal.ini"


def project_key(project: Path, name: str) -> str:
    """The key of a value that holds for one project: the hook uses the real path."""
    return f"project.{os.path.realpath(project)}.{name}"


def everywhere_key(name: str) -> str:
    """The key of a value that holds for all projects of a person."""
    return f"collabmem.{name}"


def read_value(home: Path, key: str) -> Optional[str]:
    """
    :return: The value in the personal file, or None when it is not there.
    """
    if not personal_file(home).exists():
        return None

    result = subprocess.run(
        ["git", "config", "--file", str(personal_file(home)), "--get", key],
        capture_output=True,
        text=True,
    )

    return result.stdout.strip() if result.returncode == 0 else None


def write_value(home: Path, key: str, value: str) -> None:
    personal_file(home).parent.mkdir(parents=True, exist_ok=True)

    subprocess.run(
        ["git", "config", "--file", str(personal_file(home)), key, value],
        check=True,
    )


def make_path_without_git(parent: Path) -> str:
    """
    :return: A PATH value with the tools the hook needs, and no git.
    """
    tools = parent / "tools-without-git"
    tools.mkdir()

    for tool in TOOLS_OF_THE_HOOK:
        (tools / tool).symlink_to(shutil.which(tool))

    return str(tools)


def run_hook(
    project: Path,
    home: Path,
    source: str = "startup",
    event: str = "SessionStart",
    extra_env: Optional[Dict[str, str]] = None,
    path: Optional[str] = None,
) -> subprocess.CompletedProcess:
    """
    Runs the hook the way Claude Code does.

    :param project: The project folder; the hook runs in it.
    :param home: The home folder of the person.
    :param source: How the session started: "startup", "clear", "compact"
        or "resume".
    :param event: The hook event.
    :param extra_env: Environment variables to add.
    :param path: The PATH to use; the PATH of the test run when None.

    :return: The finished process, with its output as text.
    """
    hook_input = {"hook_event_name": event, "session_id": "a-test-session"}
    if event == "SessionStart":
        hook_input["source"] = source

    env = {
        "HOME": str(home),
        "PATH": path if path is not None else os.environ["PATH"],
    }
    env.update(extra_env or {})

    return subprocess.run(
        [BASH, str(HOOK)],
        input=json.dumps(hook_input),
        capture_output=True,
        text=True,
        cwd=project,
        env=env,
    )


class HookTestCase(unittest.TestCase):
    """A temporary place with a home folder and one project in it."""

    def setUp(self) -> None:
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)

        self.root = Path(temporary.name)
        self.home = self.root / "home"
        self.home.mkdir()
        self.project = make_project(self.root)

    def session(
        self,
        source: str = "startup",
        project: Optional[Path] = None,
        **kwargs,
    ) -> str:
        """
        Starts a session and checks that the hook did not fail.

        :return: What the hook printed.
        """
        result = run_hook(project or self.project, self.home, source=source, **kwargs)

        self.assertEqual(result.returncode, 0, msg=result.stderr)

        return result.stdout

    def value(self, name: str, project: Optional[Path] = None) -> Optional[str]:
        return read_value(self.home, project_key(project or self.project, name))

    def set_value(self, name: str, value: str, project: Optional[Path] = None) -> None:
        write_value(self.home, project_key(project or self.project, name), value)

    def set_value_for_all_projects(self, name: str, value: str) -> None:
        write_value(self.home, everywhere_key(name), value)

    def had_welcome(self, entries_at_welcome: int = 0) -> None:
        """The person had their welcome for the installed version before."""
        self.set_value("welcomed", VERSION)
        self.set_value("entries-at-welcome", str(entries_at_welcome))


class TestWelcome(HookTestCase):
    """A person's first session in a project."""

    def test_person_with_no_values_gets_the_welcome_with_the_question(self) -> None:
        output = self.session()

        self.assertIn(WELCOME, output)
        self.assertIn(SIGNAL_QUESTION, output)
        self.assertIn(FULL_MESSAGE, output)
        self.assertNotIn(UPGRADE_MESSAGE, output)

    def test_welcome_without_the_question_when_there_is_no_install_id(self) -> None:
        project = make_project(self.root, name="no-install-id", install_id=False)

        output = self.session(project=project)

        self.assertIn(WELCOME, output)
        self.assertNotIn(SIGNAL_QUESTION, output)

    def test_welcome_is_given_after_clear_too(self) -> None:
        self.assertIn(WELCOME, self.session(source="clear"))

    def test_welcome_is_recorded_with_the_installed_version(self) -> None:
        self.session()

        self.assertEqual(self.value("welcomed"), VERSION)

    def test_size_of_the_memory_is_recorded_at_the_welcome(self) -> None:
        set_index_entries(self.project, 12)

        self.session()

        self.assertEqual(self.value("entries-at-welcome"), "12")

    def test_next_session_has_no_welcome(self) -> None:
        self.session()

        self.assertNotIn(WELCOME, self.session())

    def test_question_without_answer_is_pending_in_the_next_session(self) -> None:
        self.session()

        output = self.session()

        self.assertIn(PENDING_QUESTIONS, output)
        self.assertIn(INSTALL_SIGNAL, output)
        self.assertIn(FULL_MESSAGE, output)

    def test_next_session_says_nothing_when_nothing_is_due(self) -> None:
        project = make_project(self.root, name="no-install-id", install_id=False)
        self.session(project=project)

        self.assertNotIn(DEVELOPERS, self.session(project=project))

    def test_no_message_when_the_installed_version_is_unknown(self) -> None:
        project = make_project(self.root, name="no-version", version=None)

        output = self.session(project=project)

        self.assertNotIn(WELCOME, output)
        self.assertIsNone(self.value("welcomed", project=project))

    def test_project_path_with_a_space(self) -> None:
        project = make_project(self.root, name="my project")

        first = self.session(project=project)
        second = self.session(project=project)

        self.assertIn(WELCOME, first)
        self.assertEqual(self.value("welcomed", project=project), VERSION)
        self.assertNotIn(WELCOME, second)
        self.assertIn(PENDING_QUESTIONS, second)


class TestUpgradeMessage(HookTestCase):
    """The first session after a new version was installed."""

    def setUp(self) -> None:
        super().setUp()

        self.set_value("welcomed", PREVIOUS_VERSION)
        self.set_value("entries-at-welcome", "0")

    def test_upgrade_message_names_the_version_and_links_to_its_section(self) -> None:
        output = self.session()

        self.assertIn(f"{UPGRADE_MESSAGE} {VERSION} in this project", output)
        self.assertIn("release-notes.md#v187\n", output)
        self.assertNotIn(WELCOME, output)

    def test_link_for_a_version_with_a_letter(self) -> None:
        set_installed_version(self.project, "1.8.5a")

        self.assertIn("release-notes.md#v185a\n", self.session())

    def test_upgrade_message_is_recorded_and_given_once(self) -> None:
        self.session()

        self.assertEqual(self.value("welcomed"), VERSION)
        self.assertNotIn(UPGRADE_MESSAGE, self.session())

    def test_short_ask_when_the_person_agreed_before(self) -> None:
        self.set_value("signal", "sent")
        self.set_value("signal-version", PREVIOUS_VERSION)

        output = self.session()

        self.assertIn(SIGNAL_QUESTION, output)
        self.assertIn(SHORT_ASK, output)
        self.assertNotIn(FULL_MESSAGE, output)

    def test_no_question_when_the_person_declined(self) -> None:
        self.set_value("signal", "declined")
        self.set_value("signal-version", PREVIOUS_VERSION)

        output = self.session()

        self.assertIn(UPGRADE_MESSAGE, output)
        self.assertNotIn(SIGNAL_QUESTION, output)

    def test_no_question_when_the_person_answered_for_this_version(self) -> None:
        self.set_value("signal", "sent")
        self.set_value("signal-version", VERSION)

        output = self.session()

        self.assertIn(UPGRADE_MESSAGE, output)
        self.assertNotIn(SIGNAL_QUESTION, output)

    def test_full_message_when_the_person_was_never_asked(self) -> None:
        output = self.session()

        self.assertIn(UPGRADE_MESSAGE, output)
        self.assertIn(FULL_MESSAGE, output)


class TestStarQuestion(HookTestCase):
    """The star question waits until the memory grew by five entries."""

    def setUp(self) -> None:
        super().setUp()

        # No install ID: the install signal stays out of these tests.
        self.project = make_project(self.root, name="star", install_id=False)

    def test_not_reported_with_four_entries(self) -> None:
        self.had_welcome()
        set_index_entries(self.project, 4)

        self.assertNotIn(STAR_ASK, self.session())

    def test_first_ask_with_five_entries_and_no_answer(self) -> None:
        self.had_welcome()
        set_index_entries(self.project, 5)

        output = self.session()

        self.assertIn(PENDING_QUESTIONS, output)
        self.assertIn(STAR_FIRST_ASK, output)

    def test_follow_up_ask_after_maybe_later(self) -> None:
        self.had_welcome()
        set_index_entries(self.project, 5)
        self.set_value_for_all_projects("starred", "maybe-later")

        self.assertIn(STAR_FOLLOW_UP_ASK, self.session())

    def test_not_reported_after_a_final_answer(self) -> None:
        self.had_welcome()
        set_index_entries(self.project, 5)

        for answer in ("done", "declined"):
            with self.subTest(answer=answer):
                self.set_value_for_all_projects("starred", answer)

                self.assertNotIn(STAR_ASK, self.session())

    def test_never_together_with_a_welcome(self) -> None:
        set_index_entries(self.project, 20)

        output = self.session()

        self.assertIn(WELCOME, output)
        self.assertNotIn(STAR_ASK, output)

    def test_counts_from_the_welcome_in_a_memory_that_is_large_already(self) -> None:
        set_index_entries(self.project, 20)
        self.session()

        set_index_entries(self.project, 24)
        self.assertNotIn(STAR_ASK, self.session())

        set_index_entries(self.project, 25)
        self.assertIn(STAR_FIRST_ASK, self.session())

    def test_count_starts_at_the_upgrade_message_for_an_upgraded_person(self) -> None:
        # The upgrade procedure records the previous version, and no count.
        self.set_value("welcomed", PREVIOUS_VERSION)
        set_index_entries(self.project, 7)

        output = self.session()

        self.assertIn(UPGRADE_MESSAGE, output)
        self.assertEqual(self.value("entries-at-welcome"), "7")

        self.assertNotIn(STAR_ASK, self.session())

        set_index_entries(self.project, 12)
        self.assertIn(STAR_FIRST_ASK, self.session())

    def test_answer_holds_in_a_second_project_of_the_same_person(self) -> None:
        self.set_value_for_all_projects("starred", "done")

        second = make_project(self.root, name="second", entries=5, install_id=False)
        self.set_value("welcomed", VERSION, project=second)
        self.set_value("entries-at-welcome", "0", project=second)

        self.assertNotIn(STAR_ASK, self.session(project=second))

    def test_reported_together_with_a_pending_signal(self) -> None:
        project = make_project(self.root, name="both", entries=5)
        self.set_value("welcomed", VERSION, project=project)
        self.set_value("entries-at-welcome", "0", project=project)

        output = self.session(project=project)

        self.assertIn(STAR_FIRST_ASK, output)
        self.assertIn(INSTALL_SIGNAL, output)


class TestSessionThatContinues(HookTestCase):
    """After compaction or on resume: no welcome, pending questions only."""

    def test_no_welcome_and_nothing_recorded(self) -> None:
        for source in ("compact", "resume"):
            with self.subTest(source=source):
                output = self.session(source=source)

                self.assertNotIn(WELCOME, output)
                self.assertNotIn(SIGNAL_QUESTION, output)
                self.assertIsNone(self.value("welcomed"))

    def test_pending_questions_are_reported(self) -> None:
        for source in ("compact", "resume"):
            with self.subTest(source=source):
                output = self.session(source=source)

                self.assertIn(PENDING_QUESTIONS, output)
                self.assertIn(INSTALL_SIGNAL, output)

    def test_no_upgrade_message(self) -> None:
        self.set_value("welcomed", PREVIOUS_VERSION)

        for source in ("compact", "resume"):
            with self.subTest(source=source):
                self.assertNotIn(UPGRADE_MESSAGE, self.session(source=source))

        self.assertEqual(self.value("welcomed"), PREVIOUS_VERSION)


@unittest.skipIf(os.geteuid() == 0, "root can write everywhere")
class TestPersonalFileCannotBeUsed(HookTestCase):
    """The problem is reported, and nothing is asked."""

    def setUp(self) -> None:
        super().setUp()

        self.folder = personal_file(self.home).parent
        self.folder.mkdir(parents=True)

        # Give the rights back, so that the temporary folder can be removed.
        self.addCleanup(self.make_usable_again)

    def make_usable_again(self) -> None:
        self.folder.chmod(0o755)
        if personal_file(self.home).exists():
            personal_file(self.home).chmod(0o644)

    def assert_problem_reported_and_nothing_asked(self, state: str) -> None:
        output = self.session()

        self.assertIn(f"{PERSONAL_FILE_PROBLEM}: {personal_file(self.home)} is {state}.", output)
        self.assertNotIn(WELCOME, output)
        self.assertNotIn(SIGNAL_QUESTION, output)
        self.assertNotIn(PENDING_QUESTIONS, output)

    def test_folder_that_cannot_be_written_and_no_file_yet(self) -> None:
        self.folder.chmod(0o555)

        self.assert_problem_reported_and_nothing_asked("unwritable")

    def test_file_that_can_be_written_in_a_folder_that_cannot(self) -> None:
        self.had_welcome()
        self.folder.chmod(0o555)

        self.assert_problem_reported_and_nothing_asked("unwritable")

    def test_read_only_file(self) -> None:
        self.had_welcome()
        personal_file(self.home).chmod(0o444)

        self.assert_problem_reported_and_nothing_asked("unwritable")

    def test_damaged_file(self) -> None:
        personal_file(self.home).write_text("[[[ this is not a settings file\n")

        self.assert_problem_reported_and_nothing_asked("unreadable")

    def test_file_that_cannot_be_read(self) -> None:
        self.had_welcome()
        personal_file(self.home).chmod(0o000)

        self.assert_problem_reported_and_nothing_asked("unreadable")

    def test_problem_is_reported_in_every_new_session(self) -> None:
        self.folder.chmod(0o555)

        self.session()

        self.assertIn(PERSONAL_FILE_PROBLEM, self.session())

    def test_nothing_is_printed_when_a_session_continues(self) -> None:
        self.folder.chmod(0o555)

        for source in ("compact", "resume"):
            with self.subTest(source=source):
                output = self.session(source=source)

                self.assertNotIn(PERSONAL_FILE_PROBLEM, output)
                self.assertNotIn(PENDING_QUESTIONS, output)


class TestLoadCheckProbe(HookTestCase):
    """A load-check probe is read by no person, so it gets no message."""

    def test_no_message_and_nothing_written(self) -> None:
        output = self.session(extra_env={"COLLABMEM_PROBE": "1"})

        self.assertIn(LOAD_CHECK, output)
        self.assertNotIn(DEVELOPERS, output)
        self.assertFalse(personal_file(self.home).exists())

    def test_real_user_gets_the_welcome_after_a_probe(self) -> None:
        self.session(extra_env={"COLLABMEM_PROBE": "1"})

        self.assertIn(WELCOME, self.session())


class TestMachineWithoutGit(HookTestCase):
    """The hook says nothing about the developers, and does not fail."""

    def test_nothing_about_the_developers(self) -> None:
        path = make_path_without_git(self.root)

        for source in ("startup", "compact", "resume"):
            with self.subTest(source=source):
                output = self.session(source=source, path=path)

                self.assertNotIn(WELCOME, output)
                self.assertNotIn(PENDING_QUESTIONS, output)
                self.assertNotIn(PERSONAL_FILE_PROBLEM, output)

        self.assertFalse(personal_file(self.home).exists())

    def test_rest_of_the_hook_still_works(self) -> None:
        output = self.session(path=make_path_without_git(self.root))

        self.assertIn(LOAD_CHECK, output)


class TestHookEvents(HookTestCase):
    """What the hook prints per event, apart from the developers' messages."""

    def test_new_session_gets_the_load_check(self) -> None:
        for source in ("startup", "clear", "compact"):
            with self.subTest(source=source):
                self.assertIn(LOAD_CHECK, self.session(source=source))

    def test_resumed_session_gets_no_load_check(self) -> None:
        self.assertNotIn(LOAD_CHECK, self.session(source="resume"))

    def test_user_message_gets_the_timestamp_only(self) -> None:
        result = run_hook(self.project, self.home, event="UserPromptSubmit")

        self.assertEqual(result.returncode, 0, msg=result.stderr)
        self.assertRegex(result.stdout, r"^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\n$")

    def test_other_event_prints_nothing(self) -> None:
        result = run_hook(self.project, self.home, event="Stop")

        self.assertEqual(result.returncode, 0, msg=result.stderr)
        self.assertEqual(result.stdout, "")

    def test_missing_memory_files_are_reported(self) -> None:
        (self.project / "collab" / "notes.md").unlink()

        output = self.session()

        self.assertIn("WARNING: Missing collaboration memory files:", output)
        self.assertIn("collab/notes.md", output)

    def test_project_without_collab_config_uses_the_default_folder(self) -> None:
        (self.project / ".collab-config").unlink()

        self.assertIn(WELCOME, self.session())

    def test_nothing_on_standard_error(self) -> None:
        for source in ("startup", "clear", "compact", "resume"):
            with self.subTest(source=source):
                result = run_hook(self.project, self.home, source=source)

                self.assertEqual(result.stderr, "")


if __name__ == "__main__":
    unittest.main()
