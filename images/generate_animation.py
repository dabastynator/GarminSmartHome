import os
import sys
import re
import math
import subprocess
from PIL import Image
from PIL import ImageFilter
from PIL import ImageDraw
from shutil import copyfile
from subprocess import call
from xml.dom import minidom

sCenter = "SmartHome.png"
sCircle = ["script.png", "headphone.png", "switches.png", "playlist.png", "user.png"]
sResolutions = [240, 260, 280, 390]
cFrames = 10

def smootherstep(x):
	if (x < 0):
		return 0
	elif (x < 1):
		return (6 * x * x - 15 * x + 10) * x * x * x
	else:
		return 1

class Animation:

	def __init__(self, size, directory):
		self.size = size
		self.directory = directory
		self.centerImg = Image.open(self.directory + sCenter, 'r')
		self.images = []
		for img in sCircle:
			self.images.append(Image.open(self.directory + img, 'r'))

	def calcArcAngle(self, index):
		return -(index+0.5) * 360 / len(self.images) - 90

	def drawFrame(self, file, u):
		img = Image.new('RGBA', (self.size, self.size), (0, 0, 0, 255))
		dc = ImageDraw.Draw(img)
		center = self.size // 2
		img.paste(self.centerImg, (center - self.centerImg.size[0] // 2, center - self.centerImg.size[1] // 2), self.centerImg)
		animationStep = smootherstep(u)
		rAnimationStep = 1 - animationStep
		margin = 0.15 * self.size
		lineColor = 0xFF888888
		for i in range(len(self.images)):
			image = self.images[i]
			angle = 2 * i * math.pi / len(self.images)
			sin = math.sin(angle)
			cos = -math.cos(angle)
			marginFactor = 2 * smootherstep(1.5 * (u * 2 - 1.0 * i / len(self.images))) - 1
			offX = int(sin * (center - margin * marginFactor))
			offY = int(cos * (center - margin * marginFactor))
			img.paste(image, (center + offX - image.size[0] // 2, center + offY - image.size[1] // 2), image)
			
			angle = 2 * (i + 0.5) * math.pi / len(self.images)
			sin = math.sin(angle) * center
			cos = -math.cos(angle) * center
			splitLine = 0.5 + 0.5 * rAnimationStep
			dc.line((int(center + sin * splitLine), int(center + cos * splitLine), int(center + sin), int(center + cos)), width=1, fill=lineColor)
				
		degreeSize = 360 / len(self.images)
		arcAngle = self.calcArcAngle(0)
		arcFrom = arcAngle + 0.5 * degreeSize * rAnimationStep
		arcTo = arcAngle + degreeSize * (0.5 + 0.5 * animationStep)
		if arcFrom < arcTo:
			for i in range(5):
				dc.arc([i, i, self.size-2*i, self.size-2*i], arcFrom, arcTo, fill=lineColor)
				if i > 0:
					dc.arc([i, i, self.size-2*i+1, self.size-2*i+1], arcFrom, arcTo, fill=lineColor)
		img.save(file)

if __name__ == "__main__":
	print("Python version: " + sys.version)

	for res in sResolutions:
		print("Generate animation for " + str(res))
		folder = "../resources-round-" + str(res) + "x" + str(res) + "/drawables/"
		animation = Animation(res, folder)
		temp = "animation_frames_" + str(res) + "/"
		if not os.path.isdir(temp):
			os.makedirs(temp)
		for i in range(cFrames):
			file = temp + "frame_" + str(i).zfill(3) + ".png"
			animation.drawFrame(file, i / (cFrames - 1))
		i = temp + "*.png"
		o = temp + "animation.gif"
		subprocess.call("convert -delay 1 -loop 1 " + i + " " + o, shell=True)
