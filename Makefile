BUNDLE_NAME = ReadLater
ReadLater_FILES = ReadLater.m Instapaper/InstapaperRequest.m Instapaper/InstapaperSession.m
ReadLater_FRAMEWORKS = UIKit QuartzCore
ReadLater_PRIVATE_FRAMEWORKS = Preferences WebKit WebCore
ReadLater_INSTALL_PATH = /Library/ActionMenu/Plugins

include framework/makefiles/common.mk
include framework/makefiles/bundle.mk
