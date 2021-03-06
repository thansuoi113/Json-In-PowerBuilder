$PBExportHeader$w_main.srw
forward
global type w_main from window
end type
type cb_treeview from commandbutton within w_main
end type
type cb_readdataexam from commandbutton within w_main
end type
type cb_structjson from commandbutton within w_main
end type
type cb_xmlnodata from commandbutton within w_main
end type
type cb_jsontoxml from commandbutton within w_main
end type
type cb_formatjson from commandbutton within w_main
end type
type cb_createjson from commandbutton within w_main
end type
type dw_value from datawindow within w_main
end type
type dw_struct from datawindow within w_main
end type
type tv_data from treeview within w_main
end type
type mle_out from multilineedit within w_main
end type
type mle_json from multilineedit within w_main
end type
end forward

global type w_main from window
integer width = 3671
integer height = 2140
boolean titlebar = true
string title = "PB Json"
boolean controlmenu = true
boolean minbox = true
boolean maxbox = true
long backcolor = 67108864
string icon = "AppIcon!"
boolean center = true
cb_treeview cb_treeview
cb_readdataexam cb_readdataexam
cb_structjson cb_structjson
cb_xmlnodata cb_xmlnodata
cb_jsontoxml cb_jsontoxml
cb_formatjson cb_formatjson
cb_createjson cb_createjson
dw_value dw_value
dw_struct dw_struct
tv_data tv_data
mle_out mle_out
mle_json mle_json
end type
global w_main w_main

on w_main.create
this.cb_treeview=create cb_treeview
this.cb_readdataexam=create cb_readdataexam
this.cb_structjson=create cb_structjson
this.cb_xmlnodata=create cb_xmlnodata
this.cb_jsontoxml=create cb_jsontoxml
this.cb_formatjson=create cb_formatjson
this.cb_createjson=create cb_createjson
this.dw_value=create dw_value
this.dw_struct=create dw_struct
this.tv_data=create tv_data
this.mle_out=create mle_out
this.mle_json=create mle_json
this.Control[]={this.cb_treeview,&
this.cb_readdataexam,&
this.cb_structjson,&
this.cb_xmlnodata,&
this.cb_jsontoxml,&
this.cb_formatjson,&
this.cb_createjson,&
this.dw_value,&
this.dw_struct,&
this.tv_data,&
this.mle_out,&
this.mle_json}
end on

on w_main.destroy
destroy(this.cb_treeview)
destroy(this.cb_readdataexam)
destroy(this.cb_structjson)
destroy(this.cb_xmlnodata)
destroy(this.cb_jsontoxml)
destroy(this.cb_formatjson)
destroy(this.cb_createjson)
destroy(this.dw_value)
destroy(this.dw_struct)
destroy(this.tv_data)
destroy(this.mle_out)
destroy(this.mle_json)
end on

type cb_treeview from commandbutton within w_main
integer x = 1243
integer y = 192
integer width = 402
integer height = 112
integer taborder = 20
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "TreeView"
end type

event clicked;sailjson json
Integer Handle
String ls_json

ls_json = mle_json.Text
If IsNull(ls_json) Or Len(Trim(ls_json)) = 0 Then
	Return
End If

json = Create sailjson
json.parse( ls_json)
tv_data.DeleteItem( 0)
Handle = tv_data.InsertItemFirst(0, 'root', 2)
json.buildtree( tv_data, Handle, 2,3,1)
tv_data.ExpandItem( Handle)

Destroy json

end event

type cb_readdataexam from commandbutton within w_main
integer x = 1243
integer y = 832
integer width = 402
integer height = 112
integer taborder = 40
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "Get Data Ex"
end type

event clicked;//example read data from json

String ls_json
Sailjson json, ljson, ljson1, ljson2

ls_json = mle_json.Text

If Pos( ls_json , "ESB") = 0 Then Return //check invalid record
json = Create Sailjson
json.parse( ls_json )

//read top record
String ls_country, ls_sender_db
ljson = json.getattribute("ESB")
ls_country =  String(ljson.getattribute( 'COUNTRY'))
ls_sender_db = String(ljson.getattribute( 'SENDER_DB'))

//read loop record
If Pos( ls_json , "ODRD") = 0 Then Return //check invalid record
If Pos( ls_json , "RECORD") = 0 Then Return //check invalid record

any larray[]
long ll_count, ll_row
string ls_fact_no, ls_odr_no, ls_part_no
long ll_pro_qty

ljson1 = ljson.getattribute("ODRD")
ll_count = ljson1.getarray( "RECORD", larray)
If ll_count = 0 Then ll_count = 1	
For ll_row = 1 to ll_count
	If ll_count = 1 Then
		ljson2 = ljson1.getattribute("RECORD")
	Else
		ljson2 = larray[ll_row]
	End If
	 
	ls_fact_no =  string(ljson2.getattribute( 'FACT_NO'))
	ls_odr_no =  string(ljson2.getattribute( 'ODR_NO'))
	ls_part_no =  string(ljson2.getattribute( 'PART_NO'))
	ll_pro_qty =  long(ljson2.getattribute( 'PRO_QTY'))
	
	dw_value.insertrow(0)
	dw_value.SetItem(ll_row,'fact_no',ls_fact_no)
	dw_value.SetItem(ll_row,'odr_no',ls_odr_no)
	dw_value.SetItem(ll_row,'part_no',ls_part_no)
	dw_value.SetItem(ll_row,'pro_qty',ll_pro_qty)
	
next

Destroy json


/*

{
 "ESB": {
  "COUNTRY": "VN",
  "SENDER_DB": "33",
  "RECEIVE_ID": "44",
  "RECEIVE_DB": "55",
  "ODRM": {
   "RECORD": [
    {
     "FACT_NO": "Row1",
     "ODR_NO": "Row1",
     "PART_NO": "Row1",
     "ART_NO": "Row1"
    },
    {
     "FACT_NO": "Row2",
     "ODR_NO": "Row2",
     "PART_NO": "Row2",
     "ART_NO": "Row2"
    }
   ]
  },
  "ODRD": {
   "RECORD": [
    {
     "FACT_NO": "Row1",
     "ODR_NO": "Row1",
     "PART_NO": "Row1",
     "PRO_QTY": 1
    },
    {
     "FACT_NO": "Row2",
     "ODR_NO": "Row2",
     "PART_NO": "Row2",
     "PRO_QTY": 2
    },
    {
     "FACT_NO": "Row3",
     "ODR_NO": "Row3",
     "PART_NO": "Row3",
     "PRO_QTY": 3
    },
    {
     "FACT_NO": "Row4",
     "ODR_NO": "Row4",
     "PART_NO": "Row4",
     "PRO_QTY": 4
    },
    {
     "FACT_NO": "Row5",
     "ODR_NO": "Row5",
     "PART_NO": "Row5",
     "PRO_QTY": 5
    }
   ]
  }
 }
}
*/

end event

type cb_structjson from commandbutton within w_main
integer x = 1243
integer y = 704
integer width = 402
integer height = 112
integer taborder = 40
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "Struct Json"
end type

event clicked;String ls_xml, ls_json
sailjson json

dw_struct.Reset()
ls_json = mle_json.Text
If IsNull(ls_json) Or Len(Trim(ls_json)) = 0 Then
	Return
End If

json = Create sailjson
json.parse( ls_json )
json.getstruct(dw_struct)

Destroy json

end event

type cb_xmlnodata from commandbutton within w_main
integer x = 1243
integer y = 576
integer width = 402
integer height = 112
integer taborder = 30
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "XML NoData"
end type

event clicked;String ls_xml, ls_json
sailjson json

ls_json = mle_json.Text
If IsNull(ls_json) Or Len(Trim(ls_json)) = 0 Then
	Return
End If

json = Create sailjson
json.parse( ls_json)
ls_xml = json.getformatxmlnodata( '	')
mle_out.Text = ls_xml

Destroy json

end event

type cb_jsontoxml from commandbutton within w_main
integer x = 1243
integer y = 448
integer width = 402
integer height = 112
integer taborder = 30
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "Json To XML"
end type

event clicked;String ls_xml, ls_json
sailjson json

ls_json = mle_json.Text
If IsNull(ls_json) Or Len(Trim(ls_json)) = 0 Then
	Return
End If

json = Create sailjson
json.parse( ls_json )
ls_xml = json.getformatxml( '	')
mle_out.Text = ls_xml

Destroy json



end event

type cb_formatjson from commandbutton within w_main
integer x = 1243
integer y = 320
integer width = 402
integer height = 112
integer taborder = 20
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "Format Json"
end type

event clicked;sailjson json
String ls_json

ls_json = mle_json.Text
If IsNull(ls_json) Or Len(Trim(ls_json)) = 0 Then
	Return
End If

json = Create sailjson
json.parse(ls_json)
mle_out.Text = json.getformatjson( '    ')

Destroy json


end event

type cb_createjson from commandbutton within w_main
integer x = 1243
integer y = 64
integer width = 402
integer height = 112
integer taborder = 20
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "Create Json"
end type

event clicked;Sailjson ljsonin , ljsonin1, ljsonin2, ljsonin3
Long ll_row
String ls_jsonin

ljsonin = Create Sailjson
ljsonin1 = ljsonin.addobject( "ESB")
ljsonin1.setattribute( "COUNTRY", "VN")
//ljsonin1.setattribute( "SENDER_ID",{ "aaa", "bbb", "CCCC"})
ljsonin1.setattribute( "SENDER_DB", "33")
ljsonin1.setattribute( "RECEIVE_ID", "44")
ljsonin1.setattribute( "RECEIVE_DB", "55")

ljsonin2 = ljsonin1.addobject( "ODRM")
For ll_row = 1 To 2
	ljsonin3 = ljsonin2.addarrayitem( "RECORD")
	ljsonin3.setattribute( "FACT_NO", "Row" + String(ll_row))
	ljsonin3.setattribute( "ODR_NO", "Row" + String(ll_row))
	ljsonin3.setattribute( "PART_NO", "Row" + String(ll_row))
	ljsonin3.setattribute( "ART_NO", "Row" + String(ll_row))
Next

ljsonin2 = ljsonin1.addobject( "ODRD")
For ll_row = 1 To 5
	ljsonin3 = ljsonin2.addarrayitem( "RECORD")
	ljsonin3.setattribute( "FACT_NO", "Row" + String(ll_row))
	ljsonin3.setattribute( "ODR_NO", "Row" + String(ll_row))
	ljsonin3.setattribute( "PART_NO", "Row" + String(ll_row))
	ljsonin3.setattribute( "PRO_QTY", ll_row)
Next

ls_jsonin =  ljsonin.getformatjson(" ")
Destroy ljsonin

mle_json.Text = ls_jsonin

end event

type dw_value from datawindow within w_main
integer x = 1792
integer y = 1248
integer width = 1829
integer height = 768
integer taborder = 50
string title = "none"
string dataobject = "d_value"
boolean hscrollbar = true
boolean vscrollbar = true
boolean livescroll = true
borderstyle borderstyle = stylelowered!
end type

event constructor;Long ll_column
String ls_color, ls_border,ls_dw_color

ls_dw_color = This.Describe("datawindow.color")
ls_color  = "0~t if(getrow()=currentrow(), 29935871, "+ls_dw_color+")"
ls_border = "0~t if(getrow()=currentrow(), 5, 0)"

For ll_column = 1 To Long(This.Object.datawindow.column.count)
	//If  ll_column > 1 Then
		This.Modify("#"+String(ll_column)+".background.color = '"+ls_color+"'")
		This.Modify("#"+String(ll_column)+".border           = '"+ls_border+"'")
	//End If
Next
end event

type dw_struct from datawindow within w_main
integer x = 37
integer y = 1248
integer width = 1682
integer height = 768
integer taborder = 40
string title = "none"
string dataobject = "d_struct_json"
boolean hscrollbar = true
boolean vscrollbar = true
boolean livescroll = true
borderstyle borderstyle = stylelowered!
end type

event constructor;Long ll_column
String ls_color, ls_border,ls_dw_color

ls_dw_color = This.Describe("datawindow.color")
ls_color  = "0~t if(getrow()=currentrow(), 29935871, "+ls_dw_color+")"
ls_border = "0~t if(getrow()=currentrow(), 5, 0)"

For ll_column = 1 To Long(This.Object.datawindow.column.count)
	//If  ll_column > 1 Then
		This.Modify("#"+String(ll_column)+".background.color = '"+ls_color+"'")
		This.Modify("#"+String(ll_column)+".border           = '"+ls_border+"'")
	//End If
Next
end event

type tv_data from treeview within w_main
integer x = 2926
integer y = 64
integer width = 695
integer height = 1152
integer taborder = 30
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 33554432
borderstyle borderstyle = stylelowered!
string picturename[] = {"ExecuteSQL5!","Compile!","Copy!"}
long picturemaskcolor = 536870912
long statepicturemaskcolor = 536870912
end type

type mle_out from multilineedit within w_main
integer x = 1682
integer y = 64
integer width = 1170
integer height = 1152
integer taborder = 20
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 33554432
boolean hscrollbar = true
boolean vscrollbar = true
boolean autohscroll = true
boolean autovscroll = true
borderstyle borderstyle = stylelowered!
end type

type mle_json from multilineedit within w_main
integer x = 37
integer y = 64
integer width = 1170
integer height = 1152
integer taborder = 10
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 33554432
boolean hscrollbar = true
boolean vscrollbar = true
boolean autohscroll = true
boolean autovscroll = true
borderstyle borderstyle = stylelowered!
end type

