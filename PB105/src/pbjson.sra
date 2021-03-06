$PBExportHeader$pbjson.sra
$PBExportComments$Generated Application Object
forward
global type pbjson from application
end type
global transaction sqlca
global dynamicdescriptionarea sqlda
global dynamicstagingarea sqlsa
global error error
global message message
end forward

global type pbjson from application
string appname = "pbjson"
end type
global pbjson pbjson

on pbjson.create
appname="pbjson"
message=create message
sqlca=create transaction
sqlda=create dynamicdescriptionarea
sqlsa=create dynamicstagingarea
error=create error
end on

on pbjson.destroy
destroy(sqlca)
destroy(sqlda)
destroy(sqlsa)
destroy(error)
destroy(message)
end on

event open;open(w_main)
open(w_demo)
end event

