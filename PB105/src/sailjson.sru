$PBExportHeader$sailjson.sru
forward
global type sailjson from nonvisualobject
end type
type json_pair from structure within sailjson
end type
end forward

type json_pair from structure
	string		name
	any		value
end type

global type sailjson from nonvisualobject
end type
global sailjson sailjson

type variables
/*
	Sailjson:from www.pblsoft.com
	Please reserve this information
	
	Version:2.2
	Fixed bug read string include "\" will lost "\"
	
	Version:2.1
	Release date:2016-1-13
	update:add root is array. getrootarray
	
	Version:2.0
	Release date:2016-1-1
*/

private:
	json_pair pairs[]
	string is_json
	char ichars[]
	long idx, imaxlen

	treeview tree
	integer objectpcxidx, arraypcxidx, itempcxidx
	string is_ident
public:
	boolean ignoreCase = false
	integer ilevel
	string pair_index

end variables

forward prototypes
public function string parse (string as_json)
public function integer getarray (string itemname, ref any va[])
public function boolean isarray (any value)
public function any getattribute (string itemname)
private function integer of_readobject (sailjson vjson, integer alevel)
private subroutine of_error (string msg)
private subroutine skipspc ()
private function long findpairindex (string as_name)
private function string of_getformat (sailjson ajson, string ident)
private function string mymid (character vchars[], long vstart, long vlen)
public subroutine buildtree (treeview atree, long handle, integer aobjectpcxidx, integer aarraypcxidx, integer aitempcxidx)
private subroutine of_buildtree (sailjson ajson, long handle)
public subroutine setattribute (string as_name, any aa_value)
public function any addarrayitem (string arrayname)
public function any addobject (string objname)
public function string getformatjson (string ident)
private function integer of_readarray (ref any varray, integer alevel)
private subroutine of_buildtreeofarray (any varray, long handle)
private function string of_getformatofarray (any varray, string ident)
public function integer getrootarray (ref any va[])
public function string of_getxml (sailjson ajson, string ident)
public function string of_getformaxmltofarray (any varray, string ident, string as_rootnoode)
public function string getformatxml (string ident)
public function string of_getxmlnodata (sailjson ajson, string ident)
public function string of_getformaxmlnodatatofarray (any varray, string ident, string as_rootnoode)
public function string getformatxmlnodata (string ident)
public function string getstruct (datawindow adw)
public function string of_getstructarray (any varray, string ident, string as_rootnoode, datawindow adw)
public function string of_getstructnode (sailjson ajson, datawindow adw, string as_parent_node)
private subroutine of_builddw (sailjson ajson, datawindow adw)
private subroutine of_builddwofarray (any varray, datawindow adw)
public subroutine builddw (datawindow adw)
public subroutine of_get_pair (ref str_jspair ar_pair[])
end prototypes

public function string parse (string as_json);json_pair pairsnull[]
pairs = pairsnull

is_json = as_json
ichars = as_json
imaxlen = Len(as_json)
Integer li_level = 0

idx = 0
skipspc()
If ichars[idx] = '{' Then
	of_readobject(This, li_level)
ElseIf ichars[idx] = '[' Then
	Any la
	of_readarray(la, li_level)
	pairs[1].Value = la
	This.pair_index += ";root=1"
End If

Return ''

end function

public function integer getarray (string itemname, ref any va[]);Any la

la = GetAttribute(itemname)

If isArray(la) Then
	va = la
	Return UpperBound(va)
End If
Return 0

end function

public function boolean isarray (any value);Return ClassName(Value) = 'any'

end function

public function any getattribute (string itemname);Long Index
If ignoreCase Then
	itemname = Upper(itemname)
End If
Index = findpairindex(itemname)
If Index = 0 Then
	SignalError(42,"JSON.getAttribute: attribute "+String(itemname,"[general]")+" does not exists!")
	Return "!ERROR!"
End If
Return pairs[Index].Value

end function

private function integer of_readobject (sailjson vjson, integer alevel);
Integer li_level , pairidx, arrayidx
String ls_name, ls_value
Any la_value, la[], lanull[]
sailjson ljson

If ichars[idx] <> '{' Then
	Return -1
End If
li_level = alevel + 1
vjson.ilevel = li_level
skipspc()
Do While idx < imaxlen
	//read key name, the first char is "
	If ichars[idx] = '"' Then
		idx ++
		ls_name = ''
		ls_value = ''
		Do While ichars[idx] <> '"'
			ls_name = ls_name + ichars[idx]
			idx++
		Loop
		skipspc()
		If ichars[idx] <> ':' Then
			of_error("Error:Expect ':' but not found")
		End If
		skipspc()
		Choose Case ichars[idx]
			Case '"'
				//read string value
				idx ++
				Do Until ichars[idx] = '"'
					If ichars[idx] = '\' Then
						ls_value = ls_value + ichars[idx] + ichars[idx+1]
						idx = idx + 2
					Else
						ls_value = ls_value + ichars[idx]
						idx ++
					End If
				Loop
				la_value = ls_value
			Case '{'
				//read object
				ljson = Create sailjson
				of_readobject(ljson, li_level)
				la_value = ljson
			Case '['
				of_readarray(la_value, li_level)
			Case '0' To '9', '-'
				Do Until ichars[idx] = ',' Or ichars[idx] = '}'
					ls_value = ls_value + ichars[idx]
					idx ++
				Loop
				idx --
				la_value = Dec(ls_value)
			Case 't'
				If mymid(ichars, idx, 4) = 'true' Then
					idx += 3
				Else
					of_error('Error:invalid key value!')
				End If
				la_value = True
			Case 'f'
				If mymid(ichars, idx, 5) = 'false' Then
					idx += 4
				Else
					of_error('Error:invalid key value!')
				End If
				la_value = False
			Case 'n'
				If mymid(ichars, idx, 4) = 'null' Then
					idx += 3
				Else
					of_error('Error:invalid key value!')
				End If
				SetNull(la_value)
			Case Else
				of_error('Error:invalid key value!')
		End Choose
		
		pairidx ++
		vjson.pairs[pairidx].Name = ls_name
		vjson.pairs[pairidx].Value = la_value
		If ignoreCase Then
			ls_name = Upper(ls_name)
		End If
		vjson.pair_index += ";"+ls_name+"="+String(pairidx)
		
		skipspc()
		If ichars[idx] = ',' Then
			//read next key and value
			skipspc()
		ElseIf ichars[idx] = '}' Then
			Return 1
		End If
		
	Else
		of_error('Error:Expect key name with " but not found')
		Return -1
	End If
Loop

Return 1

end function

private subroutine of_error (string msg);SignalError(1025, msg)
//"sailjson.getattribute: attribute "+string(itemname,"[general]")+" does not exists!")
end subroutine

private subroutine skipspc ();Char c
IDX ++
c = ichars[IDX]
Do While c = ' ' Or c = '~r' Or c = '~n' Or c = '~t' Or c = '~b' Or c = '~f'
	IDX ++
	c = ichars[IDX]
Loop

end subroutine

private function long findpairindex (string as_name);Long p1, p2, Index

p1 = Pos( pair_index, ';'+as_name + "=" )
If p1 < 1 Then
	Return 0
End If
p1 += 2 + Len(as_name)
p2 = Pos(pair_index,';',p1)
If p2 < 1 Then
	p2 = Len( pair_index ) + 1
End If
Index = Long( Mid( pair_index, p1, p2 - p1 ) )
Return Index

end function

private function string of_getformat (sailjson ajson, string ident);String ls, ls1, ls_return, ls_ident, ls_rtn
Integer li,lj, li_max, lj_max
Any la, larray[]

If ident <> '' Then
	ls_ident = ident + is_ident
	ls_rtn = '~r~n'
End If

li_max = UpperBound(ajson.pairs)
For li = 1 To li_max
	la = ajson.pairs[li].Value
	ls = '"'+ajson.pairs[li].Name+'": '
	If ClassName(la) = 'string' Then
		ls = ls + '"'+la+'"'
	ElseIf ClassName(la) = 'decimal' Then
		ls = ls + String(la)
	ElseIf ClassName(la) = 'boolean' Then
		If la = True Then
			ls = ls + 'true'
		Else
			ls = ls + 'false'
		End If
	ElseIf IsNull(ClassName(la)) Then
		ls = ls+'null'
	ElseIf ClassName(la) = 'any' Then
		//ls = ls_names[li]
	Else
		ls = ls + String(la)
	End If
	
	
	If ClassName(la) = 'sailjson' Then
		ls = ident + ls + '{'+ls_rtn
		ls = ls + of_getformat(la, ls_ident)
		ls = ls + ident + '}'
	ElseIf ClassName(la) = 'any' Then
		ls = ident + ls + '['+ls_rtn
		ls = ls + of_getformatofarray(la, ident)
		ls = ls +ident + ']'
	Else
		ls = ident + ls
	End If
	If li = li_max Then
		ls_return += ls + ''+ls_rtn
	Else
		ls_return += ls + ','+ls_rtn
	End If
Next

Return ls_return


end function

private function string mymid (character vchars[], long vstart, long vlen);String result
Long vmax , i

vmax = UpperBound(vchars)
If vstart > vmax Then
	vstart = vmax
End If
If vstart + vlen -1 > vmax Then
	vlen = vmax - vstart +1
End If

For i = vstart To vstart + vlen -1
	result = result + vchars[i]
Next
Return result

end function

public subroutine buildtree (treeview atree, long handle, integer aobjectpcxidx, integer aarraypcxidx, integer aitempcxidx);tree = atree
objectpcxidx = aobjectpcxidx
arraypcxidx = aarraypcxidx
itempcxidx = aitempcxidx

of_buildtree(This, Handle)

end subroutine

private subroutine of_buildtree (sailjson ajson, long handle);String ls
Integer li,lj, h, pcx, h1
treeviewitem tvi
Any la, larray[]

For li = 1 To UpperBound(ajson.pairs)
	pcx = itempcxidx
	la = ajson.pairs[li].Value
	If ClassName(la) = 'string' Then
		ls = ajson.pairs[li].Name + '="'+la+'"'
	ElseIf ClassName(la) = 'decimal' Then
		ls = ajson.pairs[li].Name + '='+String(la)
	ElseIf ClassName(la) = 'boolean' Then
		ls = ajson.pairs[li].Name + '='+String(la)
	ElseIf ClassName(la) = 'any' Then
		ls = ajson.pairs[li].Name+'['+String(UpperBound(la))+']'
		pcx = arraypcxidx
	ElseIf IsNull(ClassName(la)) Then
		ls = ajson.pairs[li].Name+'=null'
	Else
		ls = ajson.pairs[li].Name
		pcx = objectpcxidx
	End If
	tvi.Label = ls
	tvi.PictureIndex = pcx
	tvi.SelectedPictureIndex = pcx
	h = tree.InsertItemLast( Handle, tvi)
	If ClassName(la) = 'sailjson' Then
		of_buildtree(la, h)
	ElseIf ClassName(la) = 'any' Then
		of_buildtreeofarray(la, h)
	End If
Next

end subroutine

public subroutine setattribute (string as_name, any aa_value);Long Index
Index = findpairindex(as_name)
If Index < 1 Then
	Index = 1 + UpperBound(pairs[])
	json_pair pair
	pairs[Index] = pair
	pairs[Index].Name = as_name
	pair_index += ";"+as_name+"="+String(Index)
End If
pairs[Index].Value = aa_value

end subroutine

public function any addarrayitem (string arrayname);sailjson ljson
any jsons[]
json_pair pair
integer index

ljson = create sailjson

index = findpairindex(arrayname)
if index < 1 then
	index = 1 + upperbound(pairs[])
	pairs[index] = pair
	pairs[index].name = arrayname
	jsons[1] = ljson
	pair_index += ";"+arrayname+"="+string(index)
else
	jsons = pairs[index].value
	jsons[upperbound(jsons)+1] = ljson
end if
pairs[index].value = jsons

return ljson

end function

public function any addobject (string objname);sailjson ljson
json_pair pair
Integer Index

Index = 1 + UpperBound(pairs[])
pairs[Index] = pair
pairs[Index].Name = objname
ljson = Create sailjson
pairs[Index].Value = ljson
pair_index += ";"+objname+"="+String(Index)

Return ljson


end function

public function string getformatjson (string ident);String ls_return
is_ident = ident

ls_return = '{'

If is_ident <> '' Then
	ls_return = ls_return + '~r~n'
End If
ls_return = ls_return + of_getformat(This,is_ident) + '}'
Return ls_return

end function

private function integer of_readarray (ref any varray, integer alevel);
Integer li_level , pairidx, arrayidx
String ls_name, ls_value
Any la_value, la[], lanull[]
sailjson ljson

arrayidx = 0
la = lanull
skipspc()
Do Until ichars[idx] = ']'
	arrayidx ++
	If ichars[idx] = '{' Then
		ljson = Create sailjson
		of_readobject(ljson, li_level)
		la[arrayidx] = ljson
	ElseIf ichars[idx] = '[' Then
		of_readarray(la_value, li_level)
		la[arrayidx] = la_value
	Else
		ls_value = ''
		Choose Case ichars[idx]
			Case '"'
				//read string value
				idx ++
				Do Until ichars[idx] = '"' Or idx > imaxlen
					If ichars[idx] = '\' Then
						ls_value = ls_value + ichars[idx] + ichars[idx+1]
						idx = idx + 2
					Else
						ls_value = ls_value + ichars[idx]
						idx ++
					End If
				Loop
				la[arrayidx] = ls_value
			Case '0' To '9', '-'
				Do Until ichars[idx] = ',' Or ichars[idx] = ']' Or idx > imaxlen
					If (ichars[idx] >= '0' And ichars[idx] <= '9') &
						Or ichars[idx] = '.' Or ichars[idx] = '-' Then
						ls_value = ls_value + ichars[idx]
						idx ++
					Else
						Exit
					End If
				Loop
				idx --
				la[arrayidx] = Dec(ls_value)
			Case 't'
				If mymid(ichars, idx, 4) = 'true' Then
					idx += 3
				Else
					of_error('Error:invalid key value!')
				End If
				la[arrayidx] = True
			Case 'f'
				If mymid(ichars, idx, 5) = 'false' Then
					idx += 4
				Else
					of_error('Error:invalid key value!')
				End If
				la[arrayidx] = False
			Case 'n'
				If mymid(ichars, idx, 4) = 'null' Then
					idx += 3
				Else
					of_error('Error:invalid key value!')
				End If
				SetNull(la[arrayidx])
			Case Else
		End Choose
		
	End If
	
	skipspc()
	If ichars[idx] = ',' Then
		skipspc()
	End If
Loop

varray = la

Return arrayidx


end function

private subroutine of_buildtreeofarray (any varray, long handle);String ls
Integer li,lj, h, pcx, h1
treeviewitem tvi
Any la, larray[]

larray = varray

For li = 1 To UpperBound(larray)
	pcx = itempcxidx
	la = larray[li]
	If ClassName(la) = 'string' Then
		ls = '"'+la+'"'
	ElseIf ClassName(la) = 'decimal' Then
		ls = String(la)
	ElseIf ClassName(la) = 'boolean' Then
		ls = String(la)
	ElseIf ClassName(la) = 'any' Then
		ls = '['+String(UpperBound(la))+']'
		pcx = arraypcxidx
	ElseIf IsNull(ClassName(la)) Then
		ls = 'null'
	Else
		ls = 'item'+String(li)
		pcx = objectpcxidx
	End If
	tvi.Label = ls
	tvi.PictureIndex = pcx
	tvi.SelectedPictureIndex = pcx
	h = tree.InsertItemLast( Handle, tvi)
	If ClassName(la) = 'sailjson' Then
		of_buildtree(la, h)
	ElseIf ClassName(la) = 'any' Then
		of_buildtreeofarray( la, h)
	End If
Next

end subroutine

private function string of_getformatofarray (any varray, string ident);String ls, ls1, ls_return, ls_ident, ls_rtn
Integer li,lj, li_max, lj_max
Any la, larray[]

If ident <> '' Then
	ls_ident = ident + is_ident
	ls_rtn = '~r~n'
End If

larray = varray
li_max = UpperBound(larray)
For li = 1 To li_max
	la = larray[li]
	ls = ''
	If ClassName(la) = 'string' Then
		ls = ls + '"'+la+'"'
	ElseIf ClassName(la) = 'decimal' Then
		ls = ls + String(la)
	ElseIf ClassName(la) = 'boolean' Then
		If la = True Then
			ls = ls + 'true'
		Else
			ls = ls + 'false'
		End If
	ElseIf IsNull(ClassName(la)) Then
		ls = ls+'null'
	Else
		ls = ls + String(la)
	End If
	
	
	If ClassName(la) = 'sailjson' Then
		ls = ls_ident + ls + '{'+ls_rtn
		ls = ls + of_getformat(la, ls_ident+is_ident)
		ls = ls + ls_ident + '}'
	ElseIf ClassName(la) = 'any' Then
		ls = ls_ident + ls + '['+ls_rtn
		ls = ls + of_getformatofarray(la, ls_ident+is_ident)
		ls = ls +ls_ident + ']'
	Else
		ls = ls_ident + ls
	End If
	If li = li_max Then
		ls_return += ls + ''+ls_rtn
	Else
		ls_return += ls + ','+ls_rtn
	End If
Next

Return ls_return


end function

public function integer getrootarray (ref any va[]);Return getarray('root', va)


end function

public function string of_getxml (sailjson ajson, string ident);
String ls, ls1, ls_return, ls_ident, ls_rtn
Integer li,lj, li_max, lj_max
Any la, larray[]
Long ll_endarray, ll_arrcnt
String ls_prenood

If ident <> '' Then
	ls_ident = ident + is_ident
	ls_rtn = '~r~n'
End If

li_max = UpperBound(ajson.pairs)
For li = 1 To li_max
	ll_endarray = 0
	la = ajson.pairs[li].Value
	ls = ""
	If ClassName(la) <> 'any' Or IsNull(ClassName(la))  Then
		ls = '<'+ajson.pairs[li].Name+'>'
	End If
	
	If ClassName(la) = 'string' Then
		
		ls = ls + la
	ElseIf ClassName(la) = 'decimal' Then
		ls = ls + String(la)
	ElseIf ClassName(la) = 'boolean' Then
		If la = True Then
			ls = ls + 'true'
		Else
			ls = ls + 'false'
		End If
	ElseIf IsNull(ClassName(la)) Then
		ls = ls+'null'
	ElseIf ClassName(la) = 'any' Then
		//ls = ls_names[li]
	Else
		ls = ls + String(la)
	End If
	
	
	If ClassName(la) = 'sailjson' Then
		
		ls = ident + ls + ls_rtn + of_getxml(la, ident)
		ls = ls + ident+  '</'+ajson.pairs[li].Name+'>' +ls_rtn
		ls_prenood = ajson.pairs[li].Name
		ll_endarray ++
		ll_arrcnt ++
		
	ElseIf ClassName(la) = 'any' Then
		
		ls = ls + of_getformaxmltofarray(la, ident,ajson.pairs[li].Name )
		ll_endarray ++
		ll_arrcnt ++
	Else
		ls = ident + ls
	End If
	
	If ll_endarray = 0 Then
		If ll_arrcnt = 0 Then
			ls = ident  + ls +'</'+ajson.pairs[li].Name+'>'
			ll_arrcnt = 0
		Else
			ls = ls +'</'+ajson.pairs[li].Name+'>'
		End If
		
		ll_endarray = 0
	End If
	
	If li = li_max Then
		ls_return += ls +ls_rtn
	Else
		ls_return += ls + ls_rtn
	End If
Next

Return ls_return


end function

public function string of_getformaxmltofarray (any varray, string ident, string as_rootnoode);
String ls, ls1, ls_return, ls_ident, ls_rtn
Integer li,lj, li_max, lj_max
Any la, larray[]

If ident <> '' Then
	ls_ident = ident + is_ident
	ls_rtn = '~r~n'
End If

larray = varray
li_max = UpperBound(larray)
For li = 1 To li_max
	la = larray[li]
	ls = ''
	If ClassName(la) = 'string' Then
		ls = ident+ ls + '<'+la+'>'
	ElseIf ClassName(la) = 'decimal' Then
		ls = ls + '<'+String(la)+'>'
	ElseIf ClassName(la) = 'boolean' Then
		If la = True Then
			ls = ls + 'true'
		Else
			ls = ls + 'false'
		End If
	ElseIf IsNull(ClassName(la)) Then
		ls = ls+'null'
	Else
		ls = ls + String(la)
	End If
	
	
	If ClassName(la) = 'sailjson' Then
		ls = ident + ls+ '<' + as_rootnoode + '>' +ls_rtn
		ls = ls + of_getxml(la, ls_ident)
		ls =   ls+ ident+ '</' + as_rootnoode + '>' +ls_rtn
		
	ElseIf ClassName(la) = 'any' Then
		ls = ls_ident + ls + '['+ls_rtn
		ls = ls + of_getformaxmltofarray(la, ls_ident+is_ident, as_rootnoode)
		ls = ls +ls_ident + ']'
	Else
		//ls = ls_ident + ls
		ls = ident + ls
	End If
	If li = li_max Then
		ls_return += ls + ls_rtn
	Else
		ls_return += ls + ls_rtn
	End If
Next

Return ls_return


end function

public function string getformatxml (string ident);
String ls_return
String ls_left
Long ll_max

is_ident = ident

ll_max = UpperBound(This.pairs)

If ll_max > 1 Then
	ls_return = '<root>'+ + '~r~n' +of_getxml(This,ident)  + + '~r~n' +  '</root>'
Else
	ls_return = of_getxml(This,ident)
End If


Return ls_return

end function

public function string of_getxmlnodata (sailjson ajson, string ident);
String ls, ls1, ls_return, ls_ident, ls_rtn
Integer li,lj, li_max, lj_max
Any la, larray[]
Long ll_endarray, ll_arrcnt
String ls_prenood

If ident <> '' Then
	ls_ident = ident + is_ident
	ls_rtn = '~r~n'
End If

li_max = UpperBound(ajson.pairs)
For li = 1 To li_max
	ll_endarray = 0
	la = ajson.pairs[li].Value
	ls = ""
	If ClassName(la) <> 'any' Or IsNull(ClassName(la))  Then
		ls = '<'+ajson.pairs[li].Name+'>'
	End If
	
	If ClassName(la) = 'sailjson' Then
		
		ls = ident + ls + ls_rtn + of_getxmlnodata(la, ident)
		ls = ls + ident+  '</'+ajson.pairs[li].Name+'>' +ls_rtn
		ls_prenood = ajson.pairs[li].Name
		ll_endarray ++
		ll_arrcnt ++
		
	ElseIf ClassName(la) = 'any' Then
		
		ls = ls + of_getformaxmlnodatatofarray(la, ident,ajson.pairs[li].Name )
		
		ll_endarray ++
		ll_arrcnt ++
	Else
		ls = ident + ls
	End If
	
	If ll_endarray = 0 Then
		If ll_arrcnt = 0 Then
			ls = ident  + ls +'</'+ajson.pairs[li].Name+'>'
			ll_arrcnt = 0
		Else
			ls = ls +'</'+ajson.pairs[li].Name+'>'
		End If
		
		ll_endarray = 0
	End If
	
	If li = li_max Then
		ls_return += ls +ls_rtn
	Else
		ls_return += ls + ls_rtn
	End If
Next

Return ls_return


end function

public function string of_getformaxmlnodatatofarray (any varray, string ident, string as_rootnoode);
String ls, ls1, ls_return, ls_ident, ls_rtn
Integer li,lj, li_max, lj_max
Any la, larray[]
String ls_noderoot

If ident <> '' Then
	ls_ident = ident + is_ident
	ls_rtn = '~r~n'
End If

larray = varray
li_max = UpperBound(larray)
For li = 1 To li_max
	la = larray[li]
	ls = ''
	
	If ClassName(la) = 'sailjson' Then
		
		If ls_noderoot = as_rootnoode And li >  1 Then
			Exit
		End If
		If li = 1 Then
			ls_noderoot = as_rootnoode
		End If
		ls = ident + ls+ '<' + as_rootnoode + '>' +ls_rtn
		ls = ls + of_getxmlnodata(la, ls_ident)
		ls =   ls+ ident+ '</' + as_rootnoode + '>' +ls_rtn
		
	ElseIf ClassName(la) = 'any' Then
		ls = ls_ident + ls + '['+ls_rtn
		ls = ls + of_getformaxmlnodatatofarray(la, ls_ident+is_ident, as_rootnoode)
		ls = ls +ls_ident + ']'
	Else
		ls = ident + ls
	End If
	If li = li_max Then
		ls_return += ls + ls_rtn
	Else
		ls_return += ls + ls_rtn
	End If
Next

Return ls_return


end function

public function string getformatxmlnodata (string ident);
String ls_return
String ls_left
Long ll_max

is_ident = ident

ll_max = UpperBound(This.pairs)

If ll_max > 1 Then
	ls_return = '<root>'+ + '~r~n' +of_getxmlnodata(This,ident)  + + '~r~n' +  '</root>'
Else
	ls_return = of_getxmlnodata(This,ident)
End If


Return ls_return

end function

public function string getstruct (datawindow adw);

String ls_return
String ls_left
Long ll_max
String ident

is_ident = " "
ident = " "

ll_max = UpperBound(This.pairs)
/*
if ll_max > 1 then
	ls_return ='<root>'+ + '~r~n' +of_getxmlnodata(this,ident)  + + '~r~n' +  '</root>'
else
	ls_return =of_getxmlnodata(this,ident)
end if
*/
of_getstructnode(This, adw, "")

Return ls_return

end function

public function string of_getstructarray (any varray, string ident, string as_rootnoode, datawindow adw);
String ls, ls1, ls_return, ls_ident, ls_rtn
Integer li,lj, li_max, lj_max
Any la, larray[]
Long ll_currow
String ls_noderoot

If ident <> '' Then
	ls_ident = ident + is_ident
	ls_rtn = '~r~n'
End If

larray = varray
li_max = UpperBound(larray)
For li = 1 To li_max
	la = larray[li]
	ls = ''
	
	If ClassName(la) = 'sailjson' Then
		If ls_noderoot = as_rootnoode And li >  1 Then
			Exit
		End If
		If li = 1 Then
			ls_noderoot = as_rootnoode
		End If
		of_getstructnode(la, adw, as_rootnoode)
		
	
	ElseIf ClassName(la) = 'any' Then
		ll_currow = adw.InsertRow(0)
		adw.SetItem(ll_currow, "col",as_rootnoode )
		adw.setitem(ll_currow, "colindex", 5)
		ls = ls + of_getstructarray(la, ls_ident+is_ident, as_rootnoode, adw)
	Else
		ls = ident + ls
	End If
	If li = li_max Then
		ls_return += ls + ls_rtn
	Else
		ls_return += ls + ls_rtn
	End If
Next

Return ls_return


end function

public function string of_getstructnode (sailjson ajson, datawindow adw, string as_parent_node);
String ls, ls1, ls_return, ls_ident, ls_rtn
Integer li,lj, li_max, lj_max
Any la, larray[]
Long ll_endarray, ll_arrcnt
String ls_prenood
Long ll_currentrow

String ident = " "

If ident <> '' Then
	ls_ident = ident + is_ident
	ls_rtn = '~r~n'
End If

li_max = UpperBound(ajson.pairs)
For li = 1 To li_max
	ll_endarray = 0
	la = ajson.pairs[li].Value
	ls = ""
	
	If ClassName(la) = 'any' Or ClassName(la) = 'sailjson' Then
	Else
		ll_currentrow = adw.InsertRow(0)
		adw.SetItem(ll_currentrow, "col", ajson.pairs[li].Name)
		adw.SetItem(ll_currentrow, "colparent", as_parent_node)
		adw.SetItem(ll_currentrow, "colindex", 1)
	End If
	If ClassName(la) = 'sailjson' Then
		ll_currentrow = adw.InsertRow(0)
		adw.SetItem(ll_currentrow, "col", ajson.pairs[li].Name)
		adw.SetItem(ll_currentrow, "colparent", as_parent_node)
		adw.SetItem(ll_currentrow, "colindex", 2)
		
		of_getstructnode(la, adw, ajson.pairs[li].Name)
		
	ElseIf ClassName(la) = 'any' Then
		adw.SetItem(ll_currentrow, "col", ajson.pairs[li].Name)
		adw.SetItem(ll_currentrow, "colparent", as_parent_node)
		adw.SetItem(ll_currentrow, "colindex", 3)
		
		of_getstructarray(la, ident,ajson.pairs[li].Name , adw)
		
	Else
		ls = ident + ls
	End If
	
Next

Return ls_return


end function

private subroutine of_builddw (sailjson ajson, datawindow adw);String ls
Integer li,lj, h, pcx, h1
treeviewitem tvi
Any la, larray[]

For li = 1 To UpperBound(ajson.pairs)
	pcx = itempcxidx
	la = ajson.pairs[li].Value
	If ClassName(la) = 'string' Then
		ls = ajson.pairs[li].Name + '="'+la+'"'
	ElseIf ClassName(la) = 'decimal' Then
		ls = ajson.pairs[li].Name + '='+String(la)
	ElseIf ClassName(la) = 'boolean' Then
		ls = ajson.pairs[li].Name + '='+String(la)
	ElseIf ClassName(la) = 'any' Then
		ls = ajson.pairs[li].Name+'['+String(UpperBound(la))+']'
		pcx = arraypcxidx
	ElseIf IsNull(ClassName(la)) Then
		ls = ajson.pairs[li].Name+'=null'
	Else
		ls = ajson.pairs[li].Name
		pcx = objectpcxidx
	End If
	If ClassName(la) = 'sailjson' Then
		of_builddw(la, adw)
	ElseIf ClassName(la) = 'any' Then
		of_buildtreeofarray(la, h)
	End If
Next

end subroutine

private subroutine of_builddwofarray (any varray, datawindow adw);String ls
Integer li,lj, h, pcx, h1
treeviewitem tvi
Any la, larray[]

larray = varray

For li = 1 To UpperBound(larray)
	pcx = itempcxidx
	la = larray[li]
	If ClassName(la) = 'string' Then
		ls = '"'+la+'"'
	ElseIf ClassName(la) = 'decimal' Then
		ls = String(la)
	ElseIf ClassName(la) = 'boolean' Then
		ls = String(la)
	ElseIf ClassName(la) = 'any' Then
		ls = '['+String(UpperBound(la))+']'
		pcx = arraypcxidx
	ElseIf IsNull(ClassName(la)) Then
		ls = 'null'
	Else
		ls = 'item'+String(li)
		pcx = objectpcxidx
	End If
	If ClassName(la) = 'sailjson' Then
		of_builddw(la, adw)
	ElseIf ClassName(la) = 'any' Then
		of_builddwofarray( la, adw)
	End If
Next

end subroutine

public subroutine builddw (datawindow adw);of_builddw(This, adw)

end subroutine

public subroutine of_get_pair (ref str_jspair ar_pair[]);str_jspair ljspair[]
ar_pair = ljspair

Int li_row

For li_row = 1 To UpperBound(pairs)
	ar_pair[li_row].Name = pairs[li_row].Name
	ar_pair[li_row].Value = pairs[li_row].Value
Next

end subroutine

on sailjson.create
call super::create
TriggerEvent( this, "constructor" )
end on

on sailjson.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

