#!/bin/sh

ibtool --plugin-dir Plugins/ --compile SBPreferencesWindow.nib SBPreferencesWindow.xib
ibtool --plugin-dir Plugins/ --compile English.lproj/MainMenu.nib English.lproj/MainMenu.xib
