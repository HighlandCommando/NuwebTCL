\documentclass{article}
\usepackage{RCS,hyperref,acronym}
\RCS$Revision: 1.3 $
\RCS$Date: 2001/03/11 20:33:30 $
\renewcommand{\Diamond}{\relax}
\title{nuweb.tcl: A TCL/Tk Front End for Nuweb}
\author{Mark Wroth}
\date{\RCSDate}
\newcommand{\app}[1]{\texttt{#1}\index{#1}}
\begin{document}\maketitle
\section{Identification}

This TCL/Tk script acts as a graphical front end to \app{Nuweb}.
This is Revision~\RCSRevision, dated \RCSDate.

\section{Background}
\label{sec:background}
 
\app{Nuweb}, by Preston Briggs, is a \textit{literate programming}
processor that produces output code files and \TeX\ documentation
files from a single source file, called a \textit{web} file.

In its original form, \app{Nuweb} is a command line utility; the user
interacts with the program by typing the command name, various command
options, and the name of the target file.  This TCL/Tk script provides
a \ac{GUI} easing the selection of the target web file, the choice of
options, and the repetitive running of \app{Nuweb}.

\section{Implementation}

\subsection{Organization}
\label{sec:org}

The basic organization of this script is a series of sections that set
up the various pieces of the \ac{GUI}, a setup of the \ac{GUI} itself,
and a set of supporting procedures.
@O nuweb.tcl @{# $Id: nuwebtcl.w,v 1.3 2001/03/11 20:33:30 Mark Exp $
@<Initialization@>
@<Set up configuration buttons@>
@<Set up the menus@>
@<Define the action buttons@>
@<Display the \ac{GUI}@>
@<Supporting procedures@>
@}

\subsection{Initial Configuration}
\label{sec:init}

Set up the initial configuration; first we get the name of 
the intended file, and then set the initial values of the various
command line options.
@D Initialization @{
@<Set target path and name@>
set noTeX   0
set noCode  0
set verbose 1
set noTest  0
set numberScraps 0
@}

Because of the way we use it, the requester that we use to get the
target file name involves several related actions; we get the full
name of the path and file, and then split it up into the path and file
name components.

There are several places where we want to execute the same set of
actions. While a procedure would do this, it's easier to use a defined
scrap; the \texttt{.tcl} script will be slightly larger, but this has
little effect.
@D Set target path and name @{
    set target [tk_getOpenFile -filetypes {
    {{Nuweb files} {.w}}
    {{All files} {""}}
    }]
set target_path [file dirname $target]
set target_name [file tail $target]
eval cd \"$target_path\"
@}

The next scrap sets up the name of the executable file.  It is stored
in a variable to facilitate changing it via a configuration menu pick.
@D Set up configuration buttons @{
set nuweb_name "nuweb"
@}

\subsection{The Configuration Buttons}
\label{sec:config}
 
The primary configuration is the name of the target file.  This
button displays the name of the currently selected file, and allows
the user to change it if desired by clicking on the button and
selecting the new file from the file requester that will appear.

This is a very compact user interface.  However, some users might not
find it intuitive (since Windows tends to provide a separate
``browse'' button next to a label widget).  I don't consider this a
problem, as I am probably the only user for this particular script.
If this script does get wider dissemination, however, consider
reimplementing this with a label and a browse button.  
@D Set up configuration buttons @{ 
button .browse -textvariable target_name -command { 
  @<Set target path and name@>
} 
label .pathname -textvariable target_path
@}

We also allow the user to set the various options of \app{nuweb}; this
section sets the options up in a two-column pane.  The option defaults
are set above (Section~\ref{sec:init}).
@D Set up configuration buttons @{ 
frame .config
frame .config.left
frame .config.right
checkbutton .noTeX -text "Suppress TeX Output" \
   -variable noTeX -anchor w
checkbutton .noCode -text "Suppress Code Output" \
   -variable noCode -anchor w
checkbutton .verbose -text "Verbose Output" \
   -variable verbose -anchor w
checkbutton .noTest -text "Do Not Test For File Changed" \
   -variable noTest -anchor w
checkbutton .numberScraps -text "Number Scraps Consecutively" \
   -variable numberScraps -anchor w

@}

\subsection{Menus}

As a convenience---and as a programming exercise---we set up a series
of menus that allow the user to perform various actions.  Some of
these capabilities duplicate the capabilities provided by other
elements of the \ac{GUI}, and some are accessible only from the menu
structure. 

The menus themselves will be contained in a frame.
@D Set up the menus @{
 frame .menubar -relief groove -borderwidth 4 
@}

The ``File'' menu 
@D Set up the menus @{
menubutton .menubar.file   -text "File" \
  -direction below -menu .menubar.file.menu 
menu .menubar.file.menu\
  -tearoff 0
.menubar.file.menu add command -label "Set target" -command {
  @<Set target path and name@>}
.menubar.file.menu add command -label "Exit" -command {
  exit}
 @}

The ``configuration'' menu.
@D Set up the menus @{
menubutton .menubar.config -text "Config" \
  -direction below -menu .menubar.config.menu
menu .menubar.config.menu \
  -tearoff 0 
.menubar.config.menu add command -label "Nuweb" -command {
  set nuweb [tk_getOpenFile -filetypes {
      {{Executables} {.exe}}
      {{All files} {""}}
  }]
  } 
@}

The ``Help'' menu.
@D Set up the menus @{
menubutton .menubar.help   -text "Help" \
  -direction below -menu .menubar.help.menu
menu .menubar.help.menu \
  -tearoff 0 
.menubar.help.menu add command -label "Help" \
	-command {showHelp}
.menubar.help.menu add command -label "About" -command {
  tk_messageBox -type ok -message \
  "This is nuweb.tcl, a TCL/Tk application providing a 
   graphical front end for Nuweb.\n\n
   Copyright (c) Mark Wroth <mark@@astrid.upland.ca.us> 2001\n\n
   Free distribution under the terms of the Gnu Public License
   is authorized."
  }
@}

Finally, the menus are packed in the top frame.
@D Set up the menus @{
pack .menubar.file .menubar.config  -side left -fill x
pack .menubar.help -side right -fill x
@}

\subsection{Actions}
 
The primary action from this script is to run the \app{nuweb}
processor with the configuration options and target selected by the
user. 

We are going to write the normal and error output of the script to log
files (via output redirection in the \texttt{exec} command).  Because
of this, As part of the initialization of this command script, we will
delete the log file so it contains only the output from this run
when they are written by redirecting the output of \app{nuweb}.

It is an oddity of \app{nuweb} that \emph{all} of its output is written 
to standard error; for this reason only the standard error is redirected
into the log file.

@D Define the action buttons @{
button .go -text "Tangle/Weave" -command {
    file delete nuwebtcl.log
    file delete nuwebtcl.error
    if $noTeX {set t " -t "}   else {set t ""}
    if $noCode {set o " -o "}  else {set o ""}
    if $verbose {set v " -v "} else {set v ""}
    if $noTest {set c " -c "}  else {set c ""}
    if $numberScraps {set n " -n "} else {set n ""}

    catch {
      eval exec $nuweb_name \
        $t $o $v $c $n \
        \"$target\" \
        2> nuwebtcl.log
    }
  if [expr [file size nuwebtcl.log] > 0] {
    showFile nuwebtcl.log
    } else {
    file delete nuwebtcl.log
    }
}
@}

Note the redirection of \app{nuweb}'s output to log files.  This
enables us to automatically display the error log if \app{nuweb} exited
abnormally. 

Once \app{nuweb} has returned, we examine the size of the redirected files.
If the error file has non-zero length, we display it, using procedures
stolen from the ``Widget Tour''.  If it, or the log file, has zero
length, we will delete it.
@D Define the action buttons @{
button .showlog -text "Show Log" -command {
  showFile nuwebtcl.log
}
@}

 Finally, we provide a button to exit from the application.  This
 is not strictly necessary, since the "close" widget automatically
 provided by the window manager has the same functionality, but it
 seems appropriate.

@D Define the action buttons @{
button .exit -text "EXIT" -command {exit}
@}


\subsection{Help Display}
\label{sec:help}

This procedure displays the text stored in the variable ``helptext'' 
which is defined in the \app{nuweb} scrap ``help text for display'').
@D Supporting procedures @{proc showHelp {} {
     set helptext "@<help text for display@>"
     set w .text
     catch {destroy $w}
     toplevel $w
     wm title $w "Nuweb TCL/Tk Help"
     wm iconname $w "text"

     frame $w.buttons 
     pack $w.buttons -side bottom -fill x -pady 2m
     button $w.buttons.dismiss -text Dismiss -command "destroy $w"
     pack $w.buttons.dismiss  -side bottom -expand 1

     text $w.text -relief sunken -bd 2 -yscrollcommand "$w.scroll set" \
        -setgrid 1 -height 30 \
        -tabs {1c 2c 3c} \
        -wrap word  
     scrollbar $w.scroll -command "$w.text yview"
     pack $w.scroll -side right -fill y
     pack $w.text -expand yes -fill both
     $w.text insert end $helptext
     $w.text mark set insert 0.0 } 
@} %$


\subsection{Display The Interface}

The actual display of the \ac{GUI} is defined by the series of pack
commands.  Since the interface is actually quite simple, the pack
commands needed to implement it are likewise not complicated.

@D Display the \ac{GUI} @{
pack .menubar -side top -fill x
pack .pathname .browse .config -side top -fill x
pack .config.left .config.right -in .config -side left
pack .noTeX .noCode -in .config.left -side top -anchor w
pack .verbose .noTest .numberScraps -in .config.right \
  -side top -anchor w
pack .go .showlog .exit -side left -expand 1 -fill x
@}


\section{Supporting Procedures}
\label{sec:spt}

The procedures shown here are relatively generic; they provide the
general function of displaying a text file.

\subsection{Show Files}

 These procedures take a single argument, the name of a text file,
 and display it in a toplevel window.

\subsubsection{The ``showFile'' Procedure}

 This procedure was adapted from \texttt{text.tcl}, a demonstration script 
 that creates a text widget that describes the basic editing functions,
 found in the ``Widget Tour'' that is part of the \ac{TCL} distribution. 
 Specifically, it is ``text.tcl,v 1.2 1998/09/14 18:23:30 stanton Exp''.
 
 The script was adapted to turn it into a procedure and to arrange to
 fill it with text read from a file rather than with a text hard coded
 into the procedure.  Additionally, the ``Show Code'' option was
 removed, since it was not relevant to this application.

@D Supporting procedures @{proc showFile {thefile} {
     set w .text
     catch {destroy $w}
     toplevel $w
     wm title $w "$thefile"
     wm iconname $w "text"

     frame $w.buttons
     pack $w.buttons -side bottom -fill x -pady 2m
     button $w.buttons.dismiss -text Dismiss -command "destroy $w"
     pack $w.buttons.dismiss  -side bottom -expand 1

     text $w.text -relief sunken -bd 2 -yscrollcommand "$w.scroll set" \
        -setgrid 1 -height 30
     scrollbar $w.scroll -command "$w.text yview"
     pack $w.scroll -side right -fill y
     pack $w.text -expand yes -fill both
     textLoadFile $w.text $thefile
     $w.text mark set insert 0.0 } 
@} %$

\subsubsection{The ``textLoadFile'' Procedure} 

This procedure is extracted from \texttt{search.tcl}, a demonstration
script found in the ``Widget Tour'' distributed with \ac{TCL}.
Specifically, it is ``Id: search.tcl,v 1.2 1998/09/14 18:23:30 stanton
Exp''.

@D Supporting procedures @{proc textLoadFile {w file} {
    if [file exists $file] {
      set f [open $file]
      $w delete 1.0 end
      while {![eof $f]} {
         $w insert end [read $f 10000]
      }
      close $f
  }
}
@}
No modifications to this procedure were needed for this application.

\appendix

\section{User Help Text}

This scrap defines the actual text to be displayed in the help window.  
Note that the entire scrap will be within quotes when it is used;
the text defined here needs to conform to the Tcl syntax.
@D help text for display @{\
OVERVIEW
This is a Tcl/Tk front end for the Nuweb literate programming \
processor. It takes a single target file and (depending on the \
command options supplied) produces a TeX source file and a set \
of code files defined in the target file.

TARGET FILE
The name of the target file is displayed in a text button near \
the top of the Nuweb.tcl window, with the path to that file \
displayed above it.  The nuweb process will execute in this \
directory, which means that all relative path names defined \
in the target file will be interpreted relative to this directory.
\tTo change the target file, click on the text button containing \
the target file name.  A file requester will appear; navigate to and \
select the new target file using the requester.  By default, the \
requester will show only files ending in \".w\", since this is the \
usual extension given to nuweb target files.
\tThe target file requester can also be summoned via the \"File\" \
menu. \n
USER OPTIONS\n
The user options for nuweb can be set by checking the option boxes \
displayed in the center of the GUI.  These options are:
\t - Suppress TeX Output: causes nuweb to omit the \"weave\" phase \
of execution.  This means that no TeX documentation file will be produced.
\t - Suppress Code Output: causes nuweb to omit the \"tangle\" phase \
of execution. This means that no code output files will be produced.
\t - Verbose Output: causes nuweb to write the names of the input and \
output files. This information (and any warning or error messages) are \
captured in a log file which is automatically displayed when nuweb \
finishes executing.  The log file can also be displayed by selecting the \
\"Show Log\" command button.
\t - Do Not Test For File Change: normally, nuweb tests to see that its \
output files have changed before actually writing them. This is intended \
to help with make file dependencies, where updating the file modification \
date can cause unnecessary compilation.  By checking this option, you can \
cause nuweb to overwrite the existing files whether they are changed or \
not.
\t - Number Scraps Consecutively: have nuweb number the scraps in the TeX \
documentation file with consecutive numbers, rather than by the page they \
are defined on.
TANGLE/WEAVE\n
To execute nuweb with the currently selected target file and options, click \
on the button labeled \"Tangle/Weave\".
CONFIGURATION\n
The Nuweb Tcl application assumes that the nuweb executable is found \
somewhere in the operating system path.  If this is not the case, the path \
to the nuweb executable can be set using the \"Config\" menu \"Nuweb\" \
option.
EXITING FROM THE APPLICATION\n
There are three different ways to exit from the Nuweb Tcl application:
\t - Click on the button marked \"Exit\"
\t - Select the \"Exit\" item on the \"File\" menu
\t - Click on the \"Close Window\" button provided by the operating \
system's window manager.
@}

\section*{Reference Material}

\subsection*{Change History}

$Log: nuwebtcl.w,v $
Revision 1.3  2001/03/11 20:33:30  Mark
Added user help.  I'm not quite sure I understand how the text widget
displays the resulting text---some of the formatting is not quite what
I expected.  But the help seems to be usable, which is enough for now.

Revision 1.2  2001/03/10 06:38:40  Mark
Added a basic menu structure.

Corrected a potentially confusing behavior which caused the script to
place the Nuweb outputs in the directory from which the script was
invoked rather than the directory in which the target file resides.

Added protection against the impacts of directory hierarchies which
contain spaces by adding quotation marks around the directory names.

Completed basic debugging and testing.  This appears to be a
functional version.


\subsection*{Acronyms}


\begin{acronym}
  \acro{GUI}{Graphical User Interface}
  \acro{TCL}{Tool Command Language}
\end{acronym}

\begin{thebibliography}{9}

\bibitem{Ousterhout94} John K. Ousterhout. \textsl{Tcl and the Tk
    Toolkit}. Reading, MA: Addison-Wesley, 1994.

\bibitem{Raines99} Paul Raines and Jeff Tranter. \textsl{TCL/TK in a
    Nutshell}. Sebastopol CA: O'Reilly \& Associates, 1999.
  
\bibitem{WidgetDemo} Sun Microsystems, Inc. ``Tk widget demonstration''.
  Distributed with TCL 8.3, copyright 1996-1997.
  
\end{thebibliography}
\end{document}
