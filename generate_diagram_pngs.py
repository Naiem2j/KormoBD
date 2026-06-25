#!/usr/bin/env python3
"""
Generate PNG images from Mermaid diagrams in markdown files
"""
import os
import re
import subprocess
import sys

def extract_mermaid_diagrams(md_file):
    """Extract mermaid code blocks from markdown file"""
    with open(md_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Find all mermaid code blocks
    pattern = r'```mermaid\n(.*?)```'
    matches = re.finditer(pattern, content, re.DOTALL)
    
    diagrams = []
    for i, match in enumerate(matches):
        diagram_code = match.group(1).strip()
        diagrams.append((i, diagram_code))
    
    return diagrams

def create_html_for_diagram(diagram_code, title):
    """Create HTML file that renders mermaid diagram"""
    html = f"""<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>{title}</title>
    <script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>
    <style>
        body {{
            margin: 20px;
            font-family: Arial, sans-serif;
            background: white;
        }}
        .mermaid {{
            display: flex;
            justify-content: center;
        }}
    </style>
</head>
<body>
    <div class="mermaid">
{diagram_code}
    </div>
    <script>
        mermaid.initialize({{ startOnLoad: true, securityLevel: 'loose', theme: 'default' }});
    </script>
</body>
</html>"""
    return html

def convert_with_playwright(html_content, output_path):
    """Convert HTML with mermaid diagram to PNG using Playwright"""
    try:
        from playwright.async_api import async_playwright
        import asyncio
        
        async def capture():
            async with async_playwright() as p:
                browser = await p.chromium.launch()
                page = await browser.new_page()
                await page.set_content(html_content)
                await page.wait_for_load_state('networkidle')
                
                # Give mermaid time to render
                await asyncio.sleep(2)
                
                # Get the mermaid diagram bounds
                bbox = await page.locator('.mermaid').bounding_box()
                if bbox:
                    await page.screenshot(
                        path=output_path,
                        clip={
                            'x': max(0, bbox['x'] - 20),
                            'y': max(0, bbox['y'] - 20),
                            'width': bbox['width'] + 40,
                            'height': bbox['height'] + 40
                        }
                    )
                else:
                    await page.screenshot(path=output_path)
                
                await browser.close()
        
        asyncio.run(capture())
        return True
    except Exception as e:
        print(f"Playwright error: {e}")
        return False

def convert_with_mermaid_cli(diagram_code, output_path):
    """Convert mermaid code to PNG using mermaid-cli"""
    try:
        # Create temporary mermaid file
        temp_file = output_path.replace('.png', '.mmd')
        with open(temp_file, 'w') as f:
            f.write(diagram_code)
        
        # Run mmdc
        result = subprocess.run([
            'mmdc',
            '-i', temp_file,
            '-o', output_path,
            '-w', '1600',
            '-H', '1000'
        ], capture_output=True, text=True)
        
        os.remove(temp_file)
        
        if result.returncode == 0:
            return True
        else:
            print(f"mmdc error: {result.stderr}")
            return False
    except FileNotFoundError:
        print("mermaid-cli not found. Install with: npm install -g @mermaid-js/mermaid-cli")
        return False
    except Exception as e:
        print(f"Error: {e}")
        return False

def main():
    files_to_process = [
        ('f:\\KormoBD\\ER_DIAGRAM.md', 'ER Diagram - KormoBD'),
        ('f:\\KormoBD\\APP_FLOW_CHART.md', 'App Flow Chart - KormoBD')
    ]
    
    for md_file, title_prefix in files_to_process:
        if not os.path.exists(md_file):
            print(f"File not found: {md_file}")
            continue
        
        print(f"\nProcessing {md_file}...")
        diagrams = extract_mermaid_diagrams(md_file)
        
        if not diagrams:
            print(f"No mermaid diagrams found in {md_file}")
            continue
        
        output_dir = os.path.dirname(md_file)
        base_name = os.path.splitext(os.path.basename(md_file))[0]
        
        for idx, diagram_code in diagrams:
            output_name = f"{base_name}_{idx+1}.png"
            output_path = os.path.join(output_dir, output_name)
            
            html_content = create_html_for_diagram(diagram_code, f"{title_prefix} - Diagram {idx+1}")
            
            print(f"Generating {output_name}...")
            
            # Try mermaid-cli first, fall back to playwright
            success = convert_with_mermaid_cli(diagram_code, output_path)
            if not success:
                print("Trying Playwright approach...")
                success = convert_with_playwright(html_content, output_path)
            
            if success:
                print(f"✓ Created {output_path}")
            else:
                print(f"✗ Failed to create {output_name}")
    
    print("\nDone!")

if __name__ == '__main__':
    main()
