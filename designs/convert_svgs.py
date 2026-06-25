import os
from cairosvg import svg2png

design_dir = os.path.dirname(__file__)

for fname in os.listdir(design_dir):
    if fname.lower().endswith('.svg'):
        svg = os.path.join(design_dir, fname)
        png = os.path.join(design_dir, fname[:-4] + '.png')
        try:
            svg2png(url=svg, write_to=png, output_width=1080, output_height=2340)
            print('Wrote', png)
        except Exception as e:
            print('Error converting', svg, e)
