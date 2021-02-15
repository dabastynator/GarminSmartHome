import os
import sys
import re
import math
from PIL import Image
from PIL import ImageFilter
from shutil import copyfile
from subprocess import call
from xml.dom import minidom

mask_file = "icons.xml"
prefix = "../"
mask_filter = ""
buffering = True;

class Resolution:

    def __init__(self, size, directory, postfix):
        self.size = size
        self.postfix = postfix
        self.directory = os.path.join(prefix, directory)
        # Ensure tailing slash
        self.directory = os.path.join(self.directory, '')

    def checkdir(self):
        if not os.path.isdir(self.directory):
            os.makedirs(self.directory);

class Color:

    def __init__(self, name, value):
        self.name = name
        self.value = value

class Mask:

    def __init__(self, name, colors, resolutions):
        self.name = name
        self.layer = {}
        self.alpha_blur = {}
        self.resolutions = resolutions
        self.hasMask = True
        self.isDirty = False
        self.generateCount = 0
        self.modify_xml = None
        self.colors = colors
        
    def load(self):
        if self.name == "none":
            self.hasMask = False
            return
        mask_file_origin = self.name + "/" + self.name
        if self.modify_xml != None:
            mask_file_origin = self.modify_xml.getAttribute("mask")
            mask_file_origin = mask_file_origin + "/" + mask_file_origin
        for res in self.resolutions:
            mask_file = mask_file_origin + ".png"
            mask_file_r = mask_file_origin + res.postfix + ".png"
            if os.path.exists(mask_file_r):
                img = Image.open(mask_file_r, 'r');
            elif os.path.exists(mask_file):
                img = Image.open(mask_file, 'r');
                img = img.resize((res.size, res.size), Image.BICUBIC)
                if buffering:
                    img.save(mask_file_r)
            elif os.path.exists(prefix + self.name + ".png"):
                img = Image.open(prefix + self.name + ".png", 'r');
                img = img.resize((res.size, res.size), Image.BICUBIC)
            elif os.path.exists(prefix + self.name + res.postfix + ".png"):
                img = Image.open(prefix + self.name + res.postfix + ".png", 'r');
            else:
                print("Invalid mask: " + self.name + res.postfix)
                sys.exit(1)
            self.layer[res] = img
            self.generateBlurMask(img, res)
        if self.modify_xml != None:
            self.applyModification(self.modify_xml, False)
            
    def applyModification(self, xmlNode, setDirty):
        if self.hasMask == False:
            return
        transform = 'none'
        if xmlNode.hasAttribute('transform'):
            transform = xmlNode.getAttribute("transform")        
        color = ""
        if xmlNode.hasAttribute('colorize'):
            color = xmlNode.getAttribute("colorize")
        translate = ""
        if xmlNode.hasAttribute('translate'):
            translate = xmlNode.getAttribute("translate")
        for res in self.resolutions:
            # Manipulate mask
            if transform == "diagonal":
                transformDiagonal(self.layer[res])
                self.generateBlurMask(self.layer[res], res)
                self.isDirty = setDirty
            if transform == "horizontally":
                transformHorizontally(self.layer[res])
                self.generateBlurMask(self.layer[res], res)
                self.isDirty = setDirty
            if transform == "vertically":
                transformVertically(self.layer[res])
                self.generateBlurMask(self.layer[res], res)
                self.isDirty = setDirty
            if len(translate) > 0:
                translateImg(self.layer[res], translate)
                self.generateBlurMask(self.layer[res], res)
                self.isDirty = setDirty
            if len(color) > 0:
                colorizeImg(self.layer[res], self.colors.get(color), color)
                self.isDirty = setDirty
            
    def generateBlurMask(self, img, res):
        mask = img.copy()
        pixels = mask.load();
        w = mask.size[0]
        h = mask.size[1]
        alpha_blur = [[0 for x in range(w)] for y in range(h)]
        self.alpha_blur[res] = alpha_blur
        for x in range(w):
            for y in range(h):
                p = pixels[x,y]
                if p[3] < 5:
                    pixels[x,y] = 255,255,255,255
                else:
                    pixels[x,y] = 0,0,0,255

        mask = mask.filter(ImageFilter.GaussianBlur(mask.size[0]/96))
        pixels = mask.load();
        for x in range(w):
            for y in range(h):
                p = pixels[x,y]
                a = p[0] / 255
                alpha_blur[x][y] = round(255 * pow(a, 70))
                
    def applyAlphaMask(self, img, res):
        if not self.hasMask:
            return
        pixels = img.load();
        w = img.size[0]
        h = img.size[1]
        alpha = self.alpha_blur[res]
        for x in range(w):
            for y in range(h):
                p = pixels[x,y]
                pixels[x,y] = p[0], p[1], p[2], min(p[3], alpha[x][y])
                
    def generateComposite(self, xmlNode):
        if self.isDirty:
            self.load()
        input_file = xmlNode.getAttribute("input")
        output_file = xmlNode.getAttribute("output")
        blur = True
        if xmlNode.hasAttribute('blur'):
            blur = xmlNode.getAttribute("blur") == "true"
        color_input = ""
        if xmlNode.hasAttribute('colorize_input'):
            color_input = xmlNode.getAttribute("colorize_input")
        transform_input = 'none'
        if xmlNode.hasAttribute('transform_input'):
            transform_input = xmlNode.getAttribute("transform_input")
        translate_input = ""
        if xmlNode.hasAttribute('translate_input'):
            translate_input = xmlNode.getAttribute("translate_input")
        blend = "composite"
        if xmlNode.hasAttribute('blend'):
            blend = xmlNode.getAttribute("blend")
        reverse_order = False
        if xmlNode.hasAttribute('reverse_order'):
            reverse_order = xmlNode.getAttribute("reverse_order") == "true"
        mix_ratio = "0.5"
        if xmlNode.hasAttribute('ratio'):
            mix_ratio = xmlNode.getAttribute("ratio")
        print("Generate " + self.name + " mask for " + input_file + " save to " + output_file)
        sys.stdout.flush()
        self.applyModification(xmlNode, True)
        for res in self.resolutions:
            input_file_r = prefix + input_file + res.postfix + ".png"
            output_file_r = res.directory + output_file + res.postfix + ".png"
            img = None
            if input_file == "none":
                img = Image.new('RGBA', (res.size, res.size), (255, 0, 0, 0))
            elif os.path.exists(input_file_r):
                img = Image.open(input_file_r, 'r')
                if img.size[0] != res.size:
                    img = img.resize((res.size, res.size), Image.BICUBIC)
            elif os.path.exists(prefix + input_file + ".png"):
                img = Image.open(prefix + input_file + ".png", 'r')
                img = img.resize((res.size, res.size), Image.BICUBIC)
                if buffering:
                    img.save(input_file_r)
            if img != None:
                # Manipulate input image
                if transform_input == "horizontally":
                    transformHorizontally(img)
                if transform_input == "diagonal":
                    transformDiagonal(img)
                if len(translate_input) > 0:
                    translateImg(img, translate_input)
                    if self.hasMask:
                        self.generateBlurMask(self.layer[res], res)
                if blur and (blend == "composite"):
                    self.applyAlphaMask(img, res)
                if len(color_input) > 0:
                    colorizeImg(img, self.colors.get(color_input), color_input)
                    
                if self.hasMask:
                    mask = self.layer[res]
                    if reverse_order:
                        mask = img
                        img = self.layer[res].copy()
                    if blend == "composite":
                        img.alpha_composite(mask)
                    if blend == "mix":
                        mixColors(img, mask, float(mix_ratio))
                img.save(output_file_r);
                self.generateCount += 1
            else:
                print("  does not exist: " + input_file_r)

def mixColors(img, mask, ratio):
    pixels = img.load()
    mask_pixel = mask.load()
    for x in range(img.size[0]):
        for y in range(img.size[1]):
            c = pixels[x,y]
            m = mask_pixel[x,y]
            c_r = 1-(m[3] / 255) * ratio
            m_r = 1-c_r
            pixels[x,y] = round(c_r*c[0] + m_r*m[0]), round(c_r*c[1] + m_r*m[1]), round(c_r*c[2] + m_r*m[2]), c[3]

def colorizeImg(img, color_alias, color_str):
    if color_alias != None:
        color_str = color_alias.value
    color_str = color_str.lstrip('#')
    lv = len(color_str)
    color = tuple((int(color_str[i:i + lv // 3], 16)/255) for i in range(0, lv, lv // 3))
    pixels = img.load();
    for x in range(img.size[0]):
        for y in range(img.size[1]):
            c = pixels[x,y]
            pixels[x,y] = round(c[0] * color[0]), round(c[1] * color[1]), round(c[2] * color[2]), c[3]

def translateImg(img, translate):
    dx = round(img.size[0] * int(translate.split("|")[0]) / 128)
    dy = round(img.size[0] * int(translate.split("|")[1]) / 128)
    copy_px = img.copy().load()
    px = img.load();
    for x in range(img.size[0]):
        for y in range(img.size[1]):
            if (x+dx >= 0) and (x+dx < img.size[0]) and (y+dy >= 0) and (y+dy < img.size[1]):
                px[x,y] = copy_px[x+dx,y+dy]
            else:
                px[x,y] = 0,0,0,0

def transformDiagonal(img):
    pixels = img.load();
    for x in range(img.size[0]):
        for y in range(x, img.size[1]):
            tmp = pixels[x,y]
            pixels[x,y] = pixels[y,x]
            pixels[y,x] = tmp
            
def transformHorizontally(img):
    pixels = img.load();
    for x in range(math.floor(img.size[0]/2)):
        for y in range(img.size[1]):
            tmp = pixels[x,y]
            pixels[x,y] = pixels[img.size[0]-x-1,y]
            pixels[img.size[0]-x-1,y] = tmp

def transformVertically(img):
    pixels = img.load();
    for x in range(img.size[0]):
        for y in range(math.floor(img.size[1]/2)):
            tmp = pixels[x,y]
            pixels[x,y] = pixels[x,img.size[1]-y-1]
            pixels[x,img.size[1]-y-1] = tmp
            
def transformImage(xmlNode):
    input_file = xmlNode.getAttribute("input")
    input_img = None
    if os.path.exists(prefix + input_file + ".png"):
        input_img = Image.open(prefix + input_file + ".png", 'r')
    output_file = xmlNode.getAttribute("output")
    transform = 'none'
    if xmlNode.hasAttribute('transform'):
        transform = xmlNode.getAttribute("transform")
    color = ""
    if xmlNode.hasAttribute('colorize'):
        color = xmlNode.getAttribute("colorize")
    translate = ""
    if xmlNode.hasAttribute('translate'):
        translate = xmlNode.getAttribute("translate")
    scale = ""
    if xmlNode.hasAttribute('scale'):
        scale = xmlNode.getAttribute("scale")
    print("Transform " + input_file + " save to " + output_file)
    sys.stdout.flush()
    for res in self.resolutions:
        input_file_r = prefix + input_file + res.postfix + ".png"
        output_file_r = res.directory + output_file + res.postfix + ".png"
        img = None
        if os.path.exists(input_file_r):
            img = Image.open(input_file_r, 'r')
        elif os.path.exists(prefix + input_file + ".png"):
            img = Image.open(prefix + input_file + ".png", 'r')
            img = img.resize((res.size, res.size), Image.BICUBIC)
            img.save(input_file_r)
        if img != None:
            if len(scale) > 0:
                if input_img == None:
                    print(prefix + input_file + ".png does not exist")
                    print("Error: Scaling requires original hight resolution part")
                    exit(1)
                scale_f = float(scale)
                img_scaled = Image.new('RGBA', (round(input_img.size[0]/scale_f), round(input_img.size[1]/scale_f)), (255, 0, 0, 0))
                pos_x = round((img_scaled.size[0] - input_img.size[0]) / 2)
                pos_y = round((img_scaled.size[1] - input_img.size[1]) / 2)
                img_scaled.alpha_composite(input_img, dest=(pos_x, pos_y))
                img = img_scaled.resize((res.size, res.size), Image.BICUBIC)
            if transform == "horizontally":
                transformHorizontally(img)
            if transform == "diagonal":
                transformDiagonal(img)
            if len(translate) > 0:
                translateImg(img, translate_input)
            if len(color) > 0:
                colorizeImg(img, color)

            img.save(output_file_r);
        else:
            print("  does not exist: " + input_file_r)

def handleIconSet(icon_set):
    prefix = icon_set.getAttribute("directory");
    buffering = icon_set.getAttribute("buffering").upper() == "TRUE";
    
    resolutions = []
    masks = {}
    colors = {}
    
    for res_entry in icon_set.getElementsByTagName("Resolution"):
        resolution = Resolution(int(res_entry.getAttribute("pixel")), res_entry.getAttribute("directory"), res_entry.getAttribute("postfix"))
        resolution.checkdir()
        resolutions.append(resolution);
        print("Add resolution " + res_entry.getAttribute("pixel"))
    
    for color_entry in icon_set.getElementsByTagName("Color"):
        color = Color(color_entry.getAttribute("name"), color_entry.getAttribute("value"))
        colors[color.name] = color
    
    for alias_entry in icon_set.getElementsByTagName("Alias"):
        mask = Mask(alias_entry.getAttribute("name"), colors, resolutions)
        mask.modify_xml = alias_entry
        mask.load()
        masks[mask.name] = mask
    
    for transform_entry in icon_set.getElementsByTagName("Transform"):
        input_file = transform_entry.getAttribute("input")
        output_file = transform_entry.getAttribute("output")
        if input_file.startswith(mask_filter) or output_file.startswith(mask_filter):
            transformImage(transform_entry)

    for mask_entry in icon_set.getElementsByTagName("Icon"):
        mask_type = "none"
        if mask_entry.hasAttribute("mask"):
            mask_type = mask_entry.getAttribute("mask")
        input_file = mask_entry.getAttribute("input")
        output_file = mask_entry.getAttribute("output")
        if input_file.startswith(mask_filter) or output_file.startswith(mask_filter):
            if mask_type in masks:
                mask = masks[mask_type]
            else:
                mask = Mask(mask_type, colors, resolutions)
                mask.load()
                masks[mask_type] = mask
            mask.generateComposite(mask_entry)
    count = 0
    for m in masks:
        count += masks[m].generateCount
    print("Finished drawing of " + str(count) + " icons.")

if __name__ == "__main__":
    print("Python version: " + sys.version)
    mask_xml = minidom.parse(mask_file)
    if len(sys.argv) > 1:
        mask_filter = sys.argv[1]

    for icon_set in mask_xml.getElementsByTagName("IconSet"):
    	handleIconSet(icon_set)
        

