"""
Renders the instruction documents from their templates.

Development-side tool, not part of an installation. Standard library only, so
the repository needs no Python dependencies.

A template holds fields in double curly braces, for example:

    {{user_friendliness}}

Each field is replaced by the content of the file that supplies it (see
FIELDS). The rendered document is committed next to the template's sources,
because AI assistants read it straight from a clone of the repository; nothing
is built on the user's machine.

Edit the template and the field files, never the rendered document.

Usage (from the repository root):

    python3 -m tools.build_instructions            # render the documents
    python3 -m tools.build_instructions --check    # exit 1 when out of sync

Run it before every release; see the release procedure.
"""
from __future__ import annotations

import argparse
import logging
import os
import re
import sys
from pathlib import Path


module_logger = logging.getLogger(os.path.basename(__file__))

REPO_ROOT = Path(__file__).resolve().parent.parent

# Template → rendered document, both relative to the repository root.
TARGETS = {
    "templates/install.md": "install.md",
}

# Field name → file that supplies its content, relative to the repository
# root. A later version may first look for a client-specific file.
FIELDS = {
    "user_friendliness": "user-friendliness.md",
}

FIELD_PATTERN = re.compile(r"\{\{\s*(?P<name>\w+)\s*\}\}")

GENERATED_NOTICE = (
    "<!-- GENERATED from {template} by tools/build_instructions.py. "
    "Edit the template and its field files, not this file. -->\n\n")


def describe_config(
    check: bool,
    logger: logging.Logger | None = None,
) -> None:
    """Log script configuration."""
    if logger is None:
        logger = module_logger

    logger.info("Configuration:")
    logger.info(f"  check: {check}")
    logger.info(f"  repo root: {REPO_ROOT}")
    logger.info(f"  targets: {TARGETS}")
    logger.info(f"  fields: {FIELDS}")


def resolve_field(name: str) -> str:
    """
    Returns the content for a field.

    :param name: Field name as written in the template.

    :return: Content of the file that supplies the field, without leading or
        trailing blank lines.

    :raises ValueError: When the field is not known.
    """
    if name not in FIELDS:
        raise ValueError(f"Unknown field '{{{{{name}}}}}'; known: {sorted(FIELDS)}")

    return (REPO_ROOT / FIELDS[name]).read_text().strip()


def render(template_text: str, template: str) -> str:
    """
    Renders a template: fills every field and prepends the generated notice.

    :param template_text: Content of the template.
    :param template: Template path, relative to the repository root; named in
        the generated notice.

    :return: The rendered document.

    :raises ValueError: When the template holds an unknown field.
    """
    rendered = FIELD_PATTERN.sub(
        lambda match: resolve_field(match.group("name")), template_text)

    return GENERATED_NOTICE.format(template=template) + rendered


def build(check: bool, logger: logging.Logger | None = None) -> list[str]:
    """
    Renders all targets.

    :param check: When True, nothing is written; out-of-sync documents are
        only reported.
    :param logger: Logger to use; defaults to the module logger.

    :return: The rendered documents that were out of sync.

    :raises ValueError: When a template holds an unknown field.
    """
    if logger is None:
        logger = module_logger

    out_of_sync = []
    for template, document in TARGETS.items():
        rendered = render((REPO_ROOT / template).read_text(), template)

        document_path = REPO_ROOT / document
        current = document_path.read_text() if document_path.exists() else None
        if rendered == current:
            logger.info(f"{document}: up to date")
            continue

        out_of_sync.append(document)
        if check:
            logger.warning(f"{document}: OUT OF SYNC with {template} "
                           "or its field files")
        else:
            document_path.write_text(rendered)
            logger.info(f"{document}: rendered from {template}")

    return out_of_sync


def main() -> int:
    logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")

    parser = argparse.ArgumentParser(description=__doc__.strip().split("\n")[0])
    parser.add_argument("--check", action="store_true",
                        help="Do not write; exit 1 when a document is out of sync")
    args = parser.parse_args()

    config = vars(args)
    describe_config(**config)

    out_of_sync = build(**config)
    return 1 if (args.check and out_of_sync) else 0


if __name__ == "__main__":
    sys.exit(main())
