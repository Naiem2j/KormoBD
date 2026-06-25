from PIL import Image, ImageDraw, ImageFont
import os

W, H = 1080, 2340
out_dir = os.path.dirname(__file__)

# try common fonts
def get_font(size, bold=False):
    candidates = [
        "C:/Windows/Fonts/arial.ttf",
        "C:/Windows/Fonts/ARIAL.TTF",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
        "/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf",
    ]
    for p in candidates:
        try:
            return ImageFont.truetype(p, size=size)
        except Exception:
            continue
    return ImageFont.load_default()

font_large = get_font(48)
font_med = get_font(28)
font_small = get_font(20)

def save(img, name):
    path = os.path.join(out_dir, name)
    img.save(path, format='PNG')
    print('Wrote', path)

# Login
img = Image.new('RGB', (W,H), 'white')
d = ImageDraw.Draw(img)
d.rectangle([(0,0),(W,520)], fill=(255,107,107))
d.text((W//2,140), 'App Logo', fill='white', anchor='mm', font=font_large)
d.rectangle([(60,560),(1020,1740)], fill=(248,249,251), outline=(230,233,239))
d.text((120,660),'Welcome back', fill=(34,34,34), font=get_font(36))
d.rectangle([(120,760),(960,844)], fill='white', outline=(224,230,240))
d.text((144,800),'Email', fill=(154,163,178), font=font_med)
d.rectangle([(120,868),(960,952)], fill='white', outline=(224,230,240))
d.text((144,908),'Password', fill=(154,163,178), font=font_med)
d.rectangle([(120,990),(480,1074)], fill=(108,92,231))
d.text((300,1032),'Login', fill='white', anchor='mm', font=get_font(22))
save(img, 'login.png')

# Create account
img = Image.new('RGB', (W,H), 'white')
d = ImageDraw.Draw(img)
d.rectangle([(0,0),(W,460)], fill=(0,184,148))
d.text((W//2,120),'Create Account', fill='white', anchor='mm', font=get_font(44))
d.rectangle([(60,560),(1020,2020)], fill=(252,253,255), outline=(233,238,246))
d.text((120,660),'Full name', fill=(34,34,34), font=font_med)
d.rectangle([(120,680),(960,764)], fill='white', outline=(224,230,240))
d.text((120,790),'Email', fill=(34,34,34), font=font_med)
d.rectangle([(120,810),(960,894)], fill='white', outline=(224,230,240))
d.text((120,920),'Password', fill=(34,34,34), font=font_med)
d.rectangle([(120,940),(960,1024)], fill='white', outline=(224,230,240))
d.rectangle([(120,1060),(960,1144)], fill=(253,121,168))
d.text((540,1112),'Create account', fill='white', anchor='mm', font=get_font(22))
save(img, 'create_account.png')

# Employee dashboard
img = Image.new('RGB', (W,H), 'white')
d = ImageDraw.Draw(img)
d.rectangle([(0,0),(W,220)], fill=(9,132,227))
d.text((60,140),'Employee Dashboard', fill='white', font=get_font(32))
d.rectangle([(60,260),(1020,460)], fill=(255,234,167), outline=(255,209,102))
d.text((120,340),'Active Jobs', fill=(45,52,54), font=get_font(28))
d.text((960,340),'12', fill=(45,52,54), font=get_font(20), anchor='rm')
# job cards
d.rectangle([(60,480),(1020,620)], fill='white', outline=(230,233,239))
d.text((120,540),'UI Designer', fill=(34,34,34), font=font_med)
d.text((120,580),'Acme Co • Dhaka', fill=(102,102,102), font=font_small)
d.rectangle([(60,640),(1020,780)], fill='white', outline=(230,233,239))
d.text((120,700),'Frontend Developer', fill=(34,34,34), font=font_med)
d.text((120,740),'Beta LLC • Remote', fill=(102,102,102), font=font_small)
save(img, 'employee_dashboard.png')

# Post job
img = Image.new('RGB', (W,H), 'white')
d = ImageDraw.Draw(img)
d.rectangle([(0,0),(W,220)], fill=(214,48,49))
d.text((60,140),'Post a Job', fill='white', font=get_font(32))
d.rectangle([(60,260),(1020,1960)], fill=(252,252,254), outline=(233,238,246))
fields = [('Job title',380), ('Company',510), ('Location',640), ('Description',770)]
for label,y in fields:
    d.text((120,y-20), label, fill=(34,34,34), font=font_med)
    height = 84 if label!='Description' else 320
    d.rectangle([(120,y),(960,y+height)], fill='white', outline=(224,230,240))
d.rectangle([(120,1110),(960,1194)], fill=(0,184,148))
d.text((540,1162),'Publish Job', fill='white', anchor='mm', font=get_font(20))
save(img, 'post_job.png')

# View application
img = Image.new('RGB', (W,H), 'white')
d = ImageDraw.Draw(img)
d.rectangle([(0,0),(W,200)], fill=(108,92,231))
d.text((60,130),'Applications', fill='white', font=get_font(28))
d.rectangle([(60,240),(1020,400)], fill='white', outline=(230,233,239))
d.text((120,320),'John Doe', fill=(34,34,34), font=font_med)
d.text((120,360),'Applied for: UI Designer', fill=(102,102,102), font=font_small)
d.text((960,320),'View', fill=(0,184,148), font=font_small, anchor='rm')
d.rectangle([(60,420),(1020,580)], fill='white', outline=(230,233,239))
d.text((120,500),'Aisha Khan', fill=(34,34,34), font=font_med)
d.text((120,540),'Applied for: Frontend Dev', fill=(102,102,102), font=font_small)
d.text((960,500),'View', fill=(0,184,148), font=font_small, anchor='rm')
save(img, 'view_application.png')

# Worker dashboard
img = Image.new('RGB', (W,H), 'white')
d = ImageDraw.Draw(img)
d.rectangle([(0,0),(W,220)], fill=(0,206,201))
d.text((60,140),'Worker Dashboard', fill='white', font=get_font(32))
d.rectangle([(60,260),(1020,400)], fill=(255,230,240), outline=(255,159,243))
d.text((120,340),'Recommended Jobs', fill=(34,34,34), font=get_font(22))
d.rectangle([(60,420),(1020,560)], fill='white', outline=(230,233,239))
d.text((120,490),'Delivery Rider', fill=(34,34,34), font=font_med)
d.text((960,490),'Apply', fill=(9,132,227), font=font_small, anchor='rm')
d.rectangle([(60,580),(1020,720)], fill='white', outline=(230,233,239))
d.text((120,650),'Warehouse Helper', fill=(34,34,34), font=font_med)
d.text((960,650),'Apply', fill=(9,132,227), font=font_small, anchor='rm')
save(img, 'worker_dashboard.png')

# Admin dashboard
img = Image.new('RGB', (W,H), 'white')
d = ImageDraw.Draw(img)
d.rectangle([(0,0),(W,220)], fill=(255,159,67))
d.text((60,140),'Admin Dashboard', fill='white', font=get_font(32))
d.rectangle([(60,260),(500,440)], fill=(255,233,198), outline=(255,216,168))
d.text((80,340),'Total Users', fill=(34,34,34), font=get_font(22))
d.text((480,340),'1,234', fill=(34,34,34), font=get_font(36), anchor='rm')
d.rectangle([(600,260),(1020,440)], fill=(230,247,255), outline=(191,233,255))
d.text((620,340),'Open Jobs', fill=(34,34,34), font=get_font(22))
d.text((980,340),'56', fill=(34,34,34), font=get_font(36), anchor='rm')
d.rectangle([(60,480),(1020,620)], fill='white', outline=(230,233,239))
d.text((120,560),'Recent activity', fill=(34,34,34), font=font_med)
save(img, 'admin_dashboard.png')

print('All PNGs written to', out_dir)
