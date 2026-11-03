import zipfile, os

# ---- helpers ----
def para(text, bold=False, size=24, color="000000", align="left", space_before=0, space_after=120):
    align_map = {"left": "left", "center": "center", "right": "right"}
    jc = align_map.get(align, "left")
    run_props = f"""
      <w:rPr>
        {'<w:b/>' if bold else ''}
        <w:sz w:val="{size}"/>
        <w:szCs w:val="{size}"/>
        <w:color w:val="{color}"/>
      </w:rPr>"""
    return f"""
  <w:p>
    <w:pPr>
      <w:jc w:val="{jc}"/>
      <w:spacing w:before="{space_before}" w:after="{space_after}"/>
    </w:pPr>
    <w:r>{run_props}
      <w:t xml:space="preserve">{text}</w:t>
    </w:r>
  </w:p>"""

def heading1(text):
    return para(text, bold=True, size=32, color="4F46E5", space_before=240, space_after=120)

def heading2(text):
    return para(text, bold=True, size=26, color="3730A3", space_before=200, space_after=80)

def body(text, bold=False):
    return para(text, bold=bold, size=22, color="0F172A", space_before=40, space_after=80)

def note(text):
    return para(text, bold=False, size=20, color="64748B", space_before=0, space_after=60)

def divider():
    return """
  <w:p>
    <w:pPr><w:pBdr><w:bottom w:val="single" w:sz="4" w:space="1" w:color="E2E8F0"/></w:pBdr>
    <w:spacing w:before="100" w:after="100"/></w:pPr>
  </w:p>"""

def table_row(cells, header=False):
    color = "4F46E5" if header else "0F172A"
    bg = "EEF2FF" if header else "FFFFFF"
    cells_xml = ""
    for c in cells:
        cells_xml += f"""
      <w:tc>
        <w:tcPr>
          <w:shd w:val="clear" w:color="auto" w:fill="{bg}"/>
          <w:tcMar><w:left w:w="100" w:type="dxa"/><w:right w:w="100" w:type="dxa"/></w:tcMar>
        </w:tcPr>
        <w:p>
          <w:pPr><w:spacing w:before="60" w:after="60"/></w:pPr>
          <w:r>
            <w:rPr>
              {'<w:b/>' if header else ''}
              <w:sz w:val="20"/>
              <w:szCs w:val="20"/>
              <w:color w:val="{color}"/>
            </w:rPr>
            <w:t xml:space="preserve">{c}</w:t>
          </w:r>
        </w:p>
      </w:tc>"""
    return f"<w:tr>{cells_xml}</w:tr>"

def table(rows):
    rows_xml = "".join(rows)
    return f"""
  <w:tbl>
    <w:tblPr>
      <w:tblStyle w:val="TableGrid"/>
      <w:tblW w:w="9000" w:type="dxa"/>
      <w:tblBorders>
        <w:top w:val="single" w:sz="4" w:color="E2E8F0"/>
        <w:left w:val="single" w:sz="4" w:color="E2E8F0"/>
        <w:bottom w:val="single" w:sz="4" w:color="E2E8F0"/>
        <w:right w:val="single" w:sz="4" w:color="E2E8F0"/>
        <w:insideH w:val="single" w:sz="4" w:color="E2E8F0"/>
        <w:insideV w:val="single" w:sz="4" w:color="E2E8F0"/>
      </w:tblBorders>
      <w:tblCellMar>
        <w:top w:w="80" w:type="dxa"/>
        <w:bottom w:w="80" w:type="dxa"/>
      </w:tblCellMar>
    </w:tblPr>
    <w:tblGrid>
      <w:gridCol w:w="2200"/>
      <w:gridCol w:w="3400"/>
      <w:gridCol w:w="1800"/>
      <w:gridCol w:w="1600"/>
    </w:tblGrid>
    {rows_xml}
  </w:tbl>"""

# ---- document body ----
content = []

# Title
content.append(para("Integrated Workforce Management System", bold=True, size=40, color="4F46E5", align="center", space_before=200, space_after=60))
content.append(para("Project Reference Card  —  Graduation Project", bold=False, size=22, color="64748B", align="center", space_before=0, space_after=40))
content.append(para("Generated: 18 October 2026", bold=False, size=18, color="94A3B8", align="center", space_before=0, space_after=300))
content.append(divider())

# Section 1
content.append(heading1("1.  Login Accounts & Passwords"))
content.append(body("All accounts use the same password:   password123", bold=True))
content.append(note("(First login will NOT ask you to change the password — you can log in directly)"))
content.append(para("", size=20, space_before=60, space_after=60))

# Accounts table
rows = [
    table_row(["Role", "Email / Username", "Password", "Account Name"], header=True),
    table_row(["ADMIN (HR)", "yahia@company.com", "password123", "Yahia Hussein"]),
    table_row(["MANAGER", "mohamed@company.com", "password123", "Mohamed"]),
    table_row(["MANAGER", "khaled@company.com", "password123", "Khaled"]),
    table_row(["MANAGER", "omar@company.com", "password123", "Omar"]),
    table_row(["MANAGER", "yousef@company.com", "password123", "Yousef"]),
    table_row(["EMPLOYEE", "ahmed.kamal@company.com", "password123", "Ahmed Kamal"]),
    table_row(["EMPLOYEE", "(any employee email)", "password123", "200 employees total"]),
]
content.append(table(rows))
content.append(para("", size=20, space_before=100, space_after=60))
content.append(note("Tip: Use yahia@company.com to test the Admin screens (Company, Payroll, Approvals, Rules)."))
content.append(note("Use mohamed@company.com to test the Manager screens (Team Radar, Approvals, Requests)."))
content.append(note("Use ahmed.kamal@company.com to test the Employee screens (Home, History, Requests, Alerts)."))
content.append(divider())

# Section 2
content.append(heading1("2.  Backend API — How to Start It"))
content.append(heading2("API Project Folder Path"))
content.append(body("C:\\Users\\Compumarts\\.gemini\\antigravity\\scratch\\WorkforceApi", bold=True))
content.append(para("", size=20, space_before=60, space_after=60))
content.append(heading2("Step-by-Step: Starting the API"))
steps = [
    "Step 1 — Open PowerShell or Windows Terminal.",
    "Step 2 — Navigate to the API folder:",
    "           cd \"C:\\Users\\Compumarts\\.gemini\\antigravity\\scratch\\WorkforceApi\"",
    "Step 3 — Run the API:",
    "           dotnet run",
    "Step 4 — Wait for this message to appear:",
    "           Now listening on: http://0.0.0.0:5050",
    "Step 5 — Leave this window OPEN while the app is running.",
    "           The emulator connects to it at:  http://10.0.2.2:5050/api",
]
for s in steps:
    content.append(body(s))
content.append(para("", size=20, space_before=60, space_after=60))
content.append(note("Important: The API must be running BEFORE you launch the Flutter app in Android Studio."))
content.append(note("If you close the PowerShell window the API stops and the app cannot login."))
content.append(divider())

# Section 3
content.append(heading1("3.  How to Make Sure the API is Stopped (Disconnected)"))
content.append(heading2("Method A — Close the Terminal Window"))
content.append(body("Simply close the PowerShell / Terminal window where dotnet run is running."))
content.append(body("The API process stops immediately when the window closes."))
content.append(para("", size=20, space_before=60, space_after=60))
content.append(heading2("Method B — Press Ctrl + C in the Terminal"))
content.append(body("Click inside the PowerShell window and press:   Ctrl + C"))
content.append(body("You will see:   Application is shutting down..."))
content.append(body("The API is now fully stopped."))
content.append(para("", size=20, space_before=60, space_after=60))
content.append(heading2("Method C — Verify Port 5050 is Free (Confirm It's Off)"))
content.append(body("Open a new PowerShell window and run:"))
content.append(body("    netstat -ano | findstr :5050", bold=True))
content.append(body("If you see NO output  →  API is OFF  (port is free)."))
content.append(body("If you see lines with 5050  →  API is STILL running."))
content.append(para("", size=20, space_before=60, space_after=60))
content.append(heading2("To Kill It by Force (if stuck)"))
content.append(body("    1.  Run:  netstat -ano | findstr :5050"))
content.append(body("    2.  Look for the PID number at the end of the line (e.g. 14532)"))
content.append(body("    3.  Run:  taskkill /PID 14532 /F"))
content.append(body("    4.  API is now fully killed."))
content.append(divider())

# Section 4
content.append(heading1("4.  Running the Flutter App from Android Studio"))
steps2 = [
    "Step 1 — Make sure the API is running (Section 2 above).",
    "Step 2 — Open Android Studio.",
    "Step 3 — Open the Flutter project at:",
    "           C:\\Users\\Compumarts\\.gemini\\antigravity\\scratch\\integrated_workforce_app",
    "Step 4 — In the top toolbar, select device:  Pixel 7 API 36  (your emulator).",
    "Step 5 — Press the green Run button  ▶  or press  Shift + F10.",
    "Step 6 — The app loads. Login with any account from Section 1 above.",
]
for s in steps2:
    content.append(body(s))
content.append(divider())

# Section 5
content.append(heading1("5.  Quick Reference Summary"))
summary_rows = [
    table_row(["Item", "Value"], header=True),
    table_row(["API Folder", "C:\\...\\WorkforceApi"]),
    table_row(["Start API command", "dotnet run"]),
    table_row(["API Port", "5050"]),
    table_row(["API URL (emulator)", "http://10.0.2.2:5050/api"]),
    table_row(["Database", "SQL Server — AttendanceDb"]),
    table_row(["Admin login", "yahia@company.com"]),
    table_row(["All passwords", "password123"]),
    table_row(["Stop API", "Ctrl+C  or close the terminal window"]),
    table_row(["Check API is off", "netstat -ano | findstr :5050  (no output = off)"]),
]

summary_table_xml = f"""
  <w:tbl>
    <w:tblPr>
      <w:tblW w:w="9000" w:type="dxa"/>
      <w:tblBorders>
        <w:top w:val="single" w:sz="4" w:color="E2E8F0"/>
        <w:left w:val="single" w:sz="4" w:color="E2E8F0"/>
        <w:bottom w:val="single" w:sz="4" w:color="E2E8F0"/>
        <w:right w:val="single" w:sz="4" w:color="E2E8F0"/>
        <w:insideH w:val="single" w:sz="4" w:color="E2E8F0"/>
        <w:insideV w:val="single" w:sz="4" w:color="E2E8F0"/>
      </w:tblBorders>
    </w:tblPr>
    <w:tblGrid><w:gridCol w:w="3000"/><w:gridCol w:w="6000"/></w:tblGrid>
    {"".join(summary_rows)}
  </w:tbl>"""
content.append(summary_table_xml)

# ---- assemble docx ----
doc_xml = f"""<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document
  xmlns:wpc="http://schemas.microsoft.com/office/word/2010/wordprocessingCanvas"
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
<w:body>
{"".join(content)}
  <w:sectPr>
    <w:pgSz w:w="12240" w:h="15840"/>
    <w:pgMar w:top="1080" w:right="1080" w:bottom="1080" w:left="1080" w:header="720" w:footer="720" w:gutter="0"/>
  </w:sectPr>
</w:body>
</w:document>"""

rels_xml = """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
</Relationships>"""

styles_xml = """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
          xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
  <w:docDefaults>
    <w:rPrDefault><w:rPr>
      <w:rFonts w:ascii="Calibri" w:hAnsi="Calibri"/>
      <w:sz w:val="22"/><w:szCs w:val="22"/>
    </w:rPr></w:rPrDefault>
  </w:docDefaults>
  <w:style w:type="table" w:styleId="TableGrid">
    <w:name w:val="Table Grid"/>
    <w:tblPr><w:tblBorders>
      <w:top w:val="single" w:sz="4" w:color="auto"/>
      <w:left w:val="single" w:sz="4" w:color="auto"/>
      <w:bottom w:val="single" w:sz="4" w:color="auto"/>
      <w:right w:val="single" w:sz="4" w:color="auto"/>
      <w:insideH w:val="single" w:sz="4" w:color="auto"/>
      <w:insideV w:val="single" w:sz="4" w:color="auto"/>
    </w:tblBorders></w:tblPr>
  </w:style>
</w:styles>"""

content_types_xml = """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
  <Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>
</Types>"""

root_rels_xml = """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
</Relationships>"""

out = r"C:\Users\Compumarts\.gemini\antigravity\scratch\WorkforceSystem_Reference.docx"
with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as z:
    z.writestr("[Content_Types].xml", content_types_xml)
    z.writestr("_rels/.rels", root_rels_xml)
    z.writestr("word/document.xml", doc_xml)
    z.writestr("word/styles.xml", styles_xml)
    z.writestr("word/_rels/document.xml.rels", rels_xml)

print(f"Done: {out}")
