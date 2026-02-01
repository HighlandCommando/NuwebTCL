# $Id: nuwebtcl.w,v 1.3 2001/03/11 20:33:30 Mark Exp $


    set target [tk_getOpenFile -filetypes {
    {{Nuweb files} {.w}}
    {{All files} {""}}
    }]
set target_path [file dirname $target]
set target_name [file tail $target]
eval cd \"$target_path\"

set noTeX   0
set noCode  0
set verbose 1
set noTest  0
set numberScraps 0


set nuweb_name "nuweb"
 
button .browse -textvariable target_name -command { 
  
      set target [tk_getOpenFile -filetypes {
      {{Nuweb files} {.w}}
      {{All files} {""}}
      }]
  set target_path [file dirname $target]
  set target_name [file tail $target]
  eval cd \"$target_path\"
  
} 
label .pathname -textvariable target_path
 
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



 frame .menubar -relief groove -borderwidth 4 

menubutton .menubar.file   -text "File" \
  -direction below -menu .menubar.file.menu 
menu .menubar.file.menu\
  -tearoff 0
.menubar.file.menu add command -label "Set target" -command {
  
      set target [tk_getOpenFile -filetypes {
      {{Nuweb files} {.w}}
      {{All files} {""}}
      }]
  set target_path [file dirname $target]
  set target_name [file tail $target]
  eval cd \"$target_path\"
  }
.menubar.file.menu add command -label "Exit" -command {
  exit}
 
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
   Copyright (c) Mark Wroth <mark@astrid.upland.ca.us> 2001\n\n
   Free distribution under the terms of the Gnu Public License
   is authorized."
  }

pack .menubar.file .menubar.config  -side left -fill x
pack .menubar.help -side right -fill x


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

button .showlog -text "Show Log" -command {
  showFile nuwebtcl.log
}

button .exit -text "EXIT" -command {exit}


pack .menubar -side top -fill x
pack .pathname .browse .config -side top -fill x
pack .config.left .config.right -in .config -side left
pack .noTeX .noCode -in .config.left -side top -anchor w
pack .verbose .noTest .numberScraps -in .config.right \
  -side top -anchor w
pack .go .showlog .exit -side left -expand 1 -fill x

proc showHelp {} {
     set helptext "\
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
                   "
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
proc showFile {thefile} {
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
proc textLoadFile {w file} {
    if [file exists $file] {
      set f [open $file]
      $w delete 1.0 end
      while {![eof $f]} {
         $w insert end [read $f 10000]
      }
      close $f
  }
}

