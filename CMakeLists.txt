cmake_minimum_required(VERSION 3.16)

project(plasma-citygrow)

set(PLASMA_VERSION "6.0.0")
set(QT_MIN_VERSION "6.6.0")
set(KF6_MIN_VERSION "6.0.0")

find_package(ECM ${KF6_MIN_VERSION} REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})
find_package(KF6 ${KF6_MIN_VERSION} REQUIRED)
find_package(Plasma ${PLASMA_VERSION} REQUIRED)

plasma_install_package(package org.kde.plasma.citygrow_debug wallpapers wallpaper)

# cmake_minimum_required(VERSION 3.16)
# 
# project(plasma-citygrow)
# 
# find_package(ECM 1.4.0 REQUIRED NO_MODULE)
# set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})
# 
# include(KDEInstallDirs)
# include(KDECMakeSettings)
# include(KDECompilerSettings NO_POLICY_SCOPE)
# include(FeatureSummary)
# 
# find_package(KF5 REQUIRED COMPONENTS
#     Plasma
#     I18n
# )
# 
# find_package(Qt5 CONFIG REQUIRED COMPONENTS
#     Qml
#     Gui
#     Core
#     Quick
# )
# 
# # add_library(citygrow MODULE package)
# # kcoreaddons_desktop_to_json(citygrow metadata.desktop)
# 
# # wallpaper applet
# # TODO: adapt "org.kde.plasma" here & elsewhere if needed (see README)
# plasma_install_package(package org.kde.plasma.citygrow wallpapers wallpaper)
# 
# # qml extension plugin
# #add_subdirectory(plugin)
# 
# feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)
