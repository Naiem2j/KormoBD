from PIL import Image, ImageDraw, ImageFont

WIDTH, HEIGHT = 1200, 800
BG = (255, 255, 255)
BOX_FILL = (240, 248, 255)
BOX_OUTLINE = (0, 70, 140)
TEXT_COLOR = (10, 10, 10)

def draw_entity(draw, x, y, w, h, title, attrs):
    draw.rectangle([x, y, x+w, y+h], fill=BOX_FILL, outline=BOX_OUTLINE, width=2)
    title_h = 20
    draw.rectangle([x, y, x+w, y+title_h], fill=(200,220,255), outline=BOX_OUTLINE)
    draw.text((x+6, y+2), title, fill=TEXT_COLOR, font=FONT)
    ay = y + title_h + 6
    for a in attrs:
        draw.text((x+8, ay), '- ' + a, fill=TEXT_COLOR, font=FONT_SMALL)
        ay += 18

def arrow(draw, x1, y1, x2, y2):
    draw.line([x1, y1, x2, y2], fill=BOX_OUTLINE, width=2)
    # simple arrowhead
    import math
    angle = math.atan2(y2-y1, x2-x1)
    ah = 10
    p1 = (x2 - ah*math.cos(angle - math.pi/6), y2 - ah*math.sin(angle - math.pi/6))
    p2 = (x2 - ah*math.cos(angle + math.pi/6), y2 - ah*math.sin(angle + math.pi/6))
    draw.polygon([p1, p2, (x2,y2)], fill=BOX_OUTLINE)

def main():
    global FONT, FONT_SMALL
    try:
        FONT = ImageFont.truetype('arial.ttf', 14)
        FONT_SMALL = ImageFont.truetype('arial.ttf', 12)
    except Exception:
        FONT = ImageFont.load_default()
        FONT_SMALL = ImageFont.load_default()

    img = Image.new('RGB', (WIDTH, HEIGHT), BG)
    draw = ImageDraw.Draw(img)

    # Entities and attributes
    user_attrs = ['id (PK)', 'name', 'role (employer/worker/admin)', 'contact', 'status']
    worker_attrs = ['id (PK)', 'userId (FK -> User.id)', 'name', 'experienceYears', 'jobType', 'contact', 'address', 'photoUrl', 'latitude', 'longitude', 'status', 'verified']
    job_attrs = ['id (PK)', 'title', 'employerId (FK -> User.id)', 'employerName', 'jobType', 'numWorkers', 'neededBy', 'location', 'wage', 'contact', 'status', 'createdAt']
    application_attrs = ['jobId (FK -> Job.id)', 'workerId (FK -> WorkerProfile.id)', 'status']
    applicant_attrs = ['name', 'contact', 'status', 'profile (snapshot)']

    # Draw boxes
    draw_entity(draw, 50, 50, 320, 160, 'User', user_attrs)
    draw_entity(draw, 450, 50, 360, 220, 'WorkerProfile', worker_attrs)
    draw_entity(draw, 50, 260, 420, 220, 'Job', job_attrs)
    draw_entity(draw, 520, 320, 300, 120, 'Application', application_attrs)
    draw_entity(draw, 850, 60, 300, 120, 'Applicant (embedded)', applicant_attrs)

    # Relations (arrows)
    # Employer (User) -> Job
    arrow(draw, 200, 210, 200, 260)
    draw.text((210, 230), 'creates', fill=TEXT_COLOR, font=FONT_SMALL)

    # WorkerProfile -> Application (workerId)
    arrow(draw, 650, 150, 650, 320)
    draw.text((660, 220), 'applies', fill=TEXT_COLOR, font=FONT_SMALL)

    # WorkerProfile -> User (belongs to)
    arrow(draw, 450, 120, 370, 120)
    draw.text((380, 100), 'belongs to', fill=TEXT_COLOR, font=FONT_SMALL)

    # Job -> Application (jobId)
    arrow(draw, 300, 370, 520, 370)
    draw.text((380, 350), 'has applications', fill=TEXT_COLOR, font=FONT_SMALL)

    # Job -> Applicant (embedded snapshot)
    arrow(draw, 470, 260, 850, 120)
    draw.text((600, 200), 'applicant snapshots', fill=TEXT_COLOR, font=FONT_SMALL)

    out = 'er_diagram.png'
    img.save(out)
    print('Saved', out)

if __name__ == '__main__':
    main()
