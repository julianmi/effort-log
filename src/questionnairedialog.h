/*
 * Copyright (c) 2015-2017 by IT Center, RWTH Aachen University
 *
 * This file is part of EffortLog, a tool for collecting software
 * development effort.
 *
 * EffortLog is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * EffortLog is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with EffortLog.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef DIALOG_H
#define DIALOG_H

#include <QApplication>
#include <QButtonGroup>
#include <QCheckBox>
#include <QComboBox>
#include <QDialog>
#include <QDialogButtonBox>
#include <QGroupBox>
#include <QHBoxLayout>
#include <QLabel>
#include <QLineEdit>
#include <QMessageBox>
#include <QPlainTextEdit>
#include <QPushButton>
#include <QRadioButton>
#include <QSettings>
#include <QTimer>
#include <QVBoxLayout>

#include "activity.h"
#include "mainwindow.h"
#include "project.h"

//! Class to handle interval-based user input
/*!
 * This class implements an interval-based questionnaire in form of a pop-up.
 * Its main purpose is to provide the user with a convient and as little as
 * possible intrusive way of inputting what he or she was working on in the last
 * minutes.
 */
class QuestionnaireDialog : public QDialog {
  Q_OBJECT
public:
  //! The main constructor.
  QuestionnaireDialog(MainWindow *window, int scheduler);
  //! Overrides the default accept() member.
  /*!
   * accept() is executed on successfully quitting the dialog. This function
   * calls all setters of Activity to store the user-provided information in
   * an Activity.
   * \see Activity
   */
  void accept() Q_DECL_OVERRIDE;
  //! Overrides the default reject() member.
  /*!
   * reject() is executed on quitting the dialog before finishing inputting all
   * the necessary information about the activity. A warning will pop up which
   * may prevent the user from unintendedly quitting the dialog. In case the
   * user quits the dialog the current logging event will be skipped. The
   * current interval will therefore be longer.
   */
  void reject() Q_DECL_OVERRIDE;

private slots:
  //! Updates the view of the dialog
  /*!
   * This method is called every minute to update the displayed message of
   * group_activities_. This shows the user the actual interval since the last
   * logging event if he or she did not answer the dialog right away.
   */
  void UpdateUI();
  //! Handles buttons for selecting a milestone
  /*!
   * This method lets the user specify a maximum of one active button in
   * m_group_. By clicking on a active button, it can be set inactive. Clicking
   * on a button when there is another active button will set the current
   * active button to inactive and activates the clicked button.
   */
  void OnPressedMButton(QAbstractButton *btn);
  //! Call to bool Project::ReadLog(QString f)
  /*!
   * This method calls bool Project::ReadLog(QString f) on the locally stored
   * project.
   *
   * \see bool Project::ReadLog(QString f)
   */
  void ReadLog();
  //! Displays a simple viewer for the created log files
  /*!
   * This method is called if the user hits the "Read Log" button.
   */
  void LogViewer();

private:
  //! Takes care of all connections
  /*!
   * This method sets up the needed connections of the dialog. Theser are:
   *  - countdown_timer -> UpdateUI(): execute UpdateUI every 60 seconds
   *  - finish_button_ -> accept(): execute accept() if finish_button_ is
   * pressed
   *  - skip_button_ -> reject(): execute reject() if skip_button_ is pressed
   */
  void CreateConnections();
  //! Sets up the view of the dialog
  /*!
   * This method initilaizes all objects needed for visualization of the dialog.
   * All objects (widgets, layouts, etc.) are bind to main_layout_. Additionally
   * this methods sets up the keybindigs for quickly choosing an activity.
   *
   * \see Dialog::main_layout_
   */
  void Setup();
  Activity *activity_; /**< An object of type Activity which holds the matching
                           activity to the dialog.*/
  bool m_button_pressed_; /**< Indicates if a button is pressed or not.*/
  QAbstractButton *last_m_button_;      /**< The lastly clicked button.*/
  QButtonGroup *activity_button_group_; /**< Holds all buttons for choosing an
                                             activity.*/
  QButtonGroup *m_group_;  /**< Holds all buttons for choosing a milestone.*/
  QLabel *activity_label_; /**< Holds a message containing the minutes since
                                 the last logging event.*/
  QPlainTextEdit *comment_box_; /**< A box to input comments on an activity.*/
  QGroupBox *group_activities_; /**< Holds activity_button_group_ with the
                                     label info_string_.*/
  QPushButton *finish_button_;  /**< Button to exit the dialog after finishing
                                     all mandatory input.*/
  QString info_string_; /**< Holds the question on what the user was working
                             on. Is updated every 60 seconds.*/
  QVBoxLayout *main_layout_; /**< The main layout of the dialog.*/
  MainWindow *main_window_;  /**< Holds a pointer to the main window.*/
  int no_logged_activities_; /**< The number of successfully logged events.*/
  QPushButton *skip_button_; /**< Button to exit the dialog without logging the
                                  event to the log file (skipping this event)*/
  Project *project_; /**< Holds a pointer to the current project. \see Project*/
  int scheduler_; /**< Denotes if the questionnaire was scheduled by the
                          set interval (=0), was manually executed (=2), or was
                          executed on closing the program (=3)*/
  QPushButton *log_button_;  /**< Button to read the current log file.*/
};

#endif // DIALOG
