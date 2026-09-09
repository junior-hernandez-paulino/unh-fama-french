"""Validate the public research package without requiring the local raw data."""

from pathlib import Path
import hashlib
import json
import re
import subprocess
import xml.etree.ElementTree as ET
import zipfile

ROOT = Path(__file__).resolve().parents[1]
NAMESPACES = {"w": "http://schemas.openxmlformats.org/wordprocessingml/2006/main",
              "a": "http://schemas.openxmlformats.org/drawingml/2006/main"}


def main():
    result = subprocess.run(["git", "ls-files", "--cached", "--others", "--exclude-standard", "-z"],
                            cwd=ROOT, capture_output=True, check=True)
    files = set(filter(None, result.stdout.decode("utf-8").split("\0")))
    required = {"README.md", "run.R", "CITATION.cff", "paper/UNH_ECO402_Paper.md",
                "paper/UNH_ECO402_Paper.docx", "paper/UNH_ECO402_Paper.pdf"}
    assert required <= files, "A required publication file is missing."
    checked_links = 0
    for name in files:
        p = ROOT / name
        assert not name.startswith(("output/", "data/reference/", ".Rproj.user/")), name
        assert not name.startswith("data/raw/") or name == "data/raw/README.md", name
        assert p.suffix.lower() not in {".xlsx", ".zip", ".pptx", ".gif"}, name
        if p.suffix.lower() == ".md":
            text = p.read_text(encoding="utf-8")
            assert chr(0x2014) not in text, name
            for link in re.findall(r"!?\[[^\]]*\]\(([^)]+)\)", text):
                if link.startswith(("http:", "https:", "#")):
                    continue
                linked = (p.parent / link.split("#")[0]).resolve()
                assert linked.is_relative_to(ROOT), (name, link)
                assert linked.relative_to(ROOT).as_posix() in files, (name, link)
                checked_links += 1

    hashes = json.loads((ROOT / "checks/reference_hashes.json").read_text(encoding="utf-8"))
    for name, expected in hashes.items():
        text = (ROOT / name).read_text(encoding="utf-8")
        assert hashlib.sha256(text.encode("utf-8")).hexdigest() == expected, name

    with zipfile.ZipFile(ROOT / "paper/UNH_ECO402_Paper.docx") as z:
        document = ET.fromstring(z.read("word/document.xml"))
    text = " ".join(t.text or "" for t in document.findall(".//w:t", NAMESPACES))
    assert "[Student Name]" not in text
    assert "Junior Hernandez Paulino" in text
    assert len(document.findall(".//w:tbl", NAMESPACES)) == 6
    assert len(document.findall(".//a:blip", NAMESPACES)) == 5
    assert "C:/Users/" not in text and "C:\\Users\\" not in text
    assert chr(0x2014) not in text
    md = (ROOT / "paper/UNH_ECO402_Paper.md").read_text(encoding="utf-8")
    for value in ["2021-05-03 to 2026-03-31", "1,234 observations", "0.51161", "0.7956",
                  "0.9833245", "0.06759", "0.05454", "0.001348", "0.058308"]:
        assert value in md and value in text, value
    for para in document.findall(".//w:p", NAMESPACES):
        para_text = "".join(t.text or "" for t in para.findall(".//w:t", NAMESPACES))
        if para_text:
            assert para_text in md.replace("<br>", ""), para_text[:100]
    print(f"PASS: {len(files)} publication files, {checked_links} relative links, reference checksums, and manuscript checks.")
    print("This check does not run regressions. Numerical reproduction requires the original local input files.")


if __name__ == "__main__":
    main()
