#!/usr/bin/perl -w

#########################################################
### 
### File: dulk.pl
### Author: Martin den Dulk
### Contact: martin@dendulk.org
### 
### ======
### 
### This file was created for the dulk IRC bot repository
### on GitHub. See: https://github.com/MartindenDulk/dulk 
### 
### ======
### 
### USAGE
### Make sure this .pl file is executable. Fill in
### the dummy config file. Save it as config.xml.
### Execute this .pl file
### 
#########################################################


##########################################################
### LIB SETTINGS
##########################################################

    use FindBin qw($RealBin);
    use lib "$RealBin/lib/";
    use lib "$RealBin/lib/dulk/plugin";

##########################################################
### USED MODULES
##########################################################
    use strict;
    use Data::Dumper;
    use dulk::Base; # Handles socket connections / Errors / ...

##########################################################
### START PRINT
##########################################################

$|++;

##########################################################
### GLOBAL VARIABLES
##########################################################

    my $bot = new dulk::Base;

##########################################################
### RETRIEVE STATUS
##########################################################
my $status = $bot->connect();