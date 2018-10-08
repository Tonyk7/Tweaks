import os, shutil
import re
for file in os.listdir("."):
	if not file.startswith(".") and os.path.isdir(file):
		if os.path.exists("%s/.DS_Store" % file):
			os.remove("%s/.DS_Store" % file)
		if os.path.exists("%s/.theos" % file):
			shutil.rmtree("%s/.theos" % file)
		if os.path.exists("%s/packages" % file):
			shutil.rmtree("%s/packages" % file)
		if os.path.exists("%s/obj" % file):
			shutil.rmtree("%s/obj" % file)
		if os.path.exists("%s/sim.sh" % file):
			os.remove("%s/sim.sh" % file)
		# pref files
		if os.path.exists("%s/%sprefs/.DS_Store" % (file, file)):
			os.remove("%s/%sprefs/.DS_Store" % (file, file))
		if os.path.exists("%s/%sprefs/Resources/.DS_Store" % (file, file)):
			os.remove("%s/%sprefs/Resources/.DS_Store" % (file, file))


# tweaks_in_readme = []

# with open("README.md") as readme:
# 	f = re.findall("\((.*)\)", readme)
# 	print(f)
# # print(os.listdir("."))