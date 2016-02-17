#------------------------------------------------------------------------------#
#  Copyright © 2016 by IT Center, RWTH Aachen University
#
#  This file is part of EffortLog, a tool for collecting software
#  development effort.
#
#  EffortLog is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  EffortLog is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with EffortLog.  If not, see <http://www.gnu.org/licenses/>.
#------------------------------------------------------------------------------#

TARGET = effort-log
macx:TARGET = EffortLog
TEMPLATE = app
VERSION = 0.7
DEFINES += APP_VERSION=\\\"$$VERSION\\\"
QT += core gui
greaterThan(QT_MAJOR_VERSION, 4): QT += widgets
SSL_WIN = "C:\\OpenSSL-Win32"

# Compiler flags
CONFIG += c++11
QMAKE_CXXFLAGS += -fno-exceptions
CONFIG(debug, debug|release) {
  QMAKE_CXXFLAGS += -Werror
  QMAKE_CXXFLAGS += -Wextra
  QMAKE_CXXFLAGS += -Wpedantic
}

# Build directory
CONFIG(debug, debug|release) {
  DESTDIR = build/debug
}
CONFIG(release, debug|release) {
  DESTDIR = build/release
}
OBJECTS_DIR = $$DESTDIR/.obj
MOC_DIR = $$DESTDIR/.moc
RCC_DIR = $$DESTDIR/.qrc
UI_DIR = $$DESTDIR/.u
QMAKE_DISTCLEAN += -rf build

# Support for encryption
CONFIG(crypt) {
  message(Configuring EffortLog to be build with encryption.)
  DEFINES += CRYPT
  SOURCES += src/crypt.cc
  SOURCES += src/passworddialog.cc
  HEADERS += src/crypt.h
  HEADERS += src/passworddialog.h
  unix {
    # Check for SLL libraries; if SLL is not found add your local path
    exists(/usr/local/include):INCLUDEPATH += /usr/local/include
    exists(/usr/local/ssl/include):INCLUDEPATH += /usr/local/ssl/include
    exists(/usr/local/openssl/include):INCLUDEPATH += /usr/local/openssl/include
    exists(/usr/local/opt/openssl/include):INCLUDEPATH += /usr/local/opt/openssl/include
    exists(/opt/ssl/include):INCLUDEPATH += /opt/ssl/include
    exists(/opt/openssl/include):INCLUDEPATH += /opt/openssl/include
    exists(/usr/local/lib):LIBS += -L/usr/local/lib
    exists(/usr/local/ssl/lib):LIBS += -L/usr/local/ssl/lib
    exists(/usr/local/openssl/lib):LIBS += -L/usr/local/openssl/lib
    exists(/usr/local/opt/openssl/lib):LIBS += -L/usr/local/opt/openssl/lib
    exists(/opt/ssl/lib):LIBS += -L/opt/ssl/lib
    exists(/opt/openssl/lib):LIBS += -L/opt/openssl/lib
    LIBS += -lssl -lcrypto
  }
  win32 {
    # Adapt 'C:\OpenSSL-Win32' to your local path
    INCLUDEPATH += $${SSL_WIN}\\include
    LIBS += -L$${SSL_WIN}\\bin -leay32
  }
}

# OS X
macx {
  CONFIG += app_bundle
  QMAKE_INFO_PLIST = $$PWD/resources/Info.plist
  INFO_PLIST_PATH = $$shell_quote($${DESTDIR}/$${TARGET}.app/Contents/Info.plist)
  QMAKE_POST_LINK += /usr/libexec/PlistBuddy -c \"Set :CFBundleGetInfoString Version $${VERSION} IT Center RWTH Achen University\" $${INFO_PLIST_PATH};
  QMAKE_POST_LINK += /usr/libexec/PlistBuddy -c \"Set :CFBundleLongVersionString Version $${VERSION} IT Center RWTH Achen University\" $${INFO_PLIST_PATH};
  QMAKE_POST_LINK +=  /usr/libexec/PlistBuddy -c \"Set :CFBundleShortVersionString $${VERSION}\" $${INFO_PLIST_PATH};
  QMAKE_POST_LINK += /usr/libexec/PlistBuddy -c \"Set :CFBundleVersion $${VERSION}\" $${INFO_PLIST_PATH};
}

# Linux
unix:!macx {
  CONFIG += static
}

# Doxygen
doxygen.target = doxygen
doxygen.commands = doxygen Doxyfile
QMAKE_EXTRA_TARGETS += doxygen
QMAKE_CLEAN += -r doxygen

# Deployment
CONFIG(release, debug|release) {
  mac {
    QMAKE_POST_LINK += cd $${DESTDIR};
    QMAKE_POST_LINK += $$[QT_INSTALL_BINS]/macdeployqt $${TARGET}.app -dmg;
    crypt {
      QMAKE_POST_LINK += mv $${TARGET}.dmg $${TARGET}_v$${VERSION}_encrypted.dmg;
    } else {
      QMAKE_POST_LINK += mv $${TARGET}.dmg $${TARGET}_v$${VERSION}.dmg;
    }
  }
  win32 {
    QMAKE_POST_LINK += $$[QT_INSTALL_BINS]/windeployqt $$shell_quote($$DESTDIR/$$TARGET.exe) \
                       & cd $${DESTDIR} \
                       & copy $${SSL_WIN}\\libeay32.dll libeay32.dll \
                       & copy $${SSL_WIN}\\libssl32.dll libssl32.dll \
                       & copy $${SSL_WIN}\\ssleay32.dll ssleay32.dll
  }
}

SOURCES += \
  src/activity.cc \
  src/appenddialog.cc \
  src/main.cc \
  src/mainwindow.cc \
  src/milestone.cc \
  src/milestonedialog.cc \
  src/project.cc \
  src/setupdialog.cc \
  src/proinitdialog.cc \
  src/questionnairedialog.cc

HEADERS +=  \
  src/activity.h \
  src/appenddialog.h \
  src/definitions.h \
  src/mainwindow.h \
  src/milestone.h \
  src/milestonedialog.h \
  src/project.h \
  src/setupdialog.h \
  src/proinitdialog.h \
  src/questionnairedialog.h

RESOURCES += \
  doc/doc.qrc \
  resources/img.qrc

OTHER_FILES += \
  resources/Info.plist \
  Doxyfile \
  README.md
