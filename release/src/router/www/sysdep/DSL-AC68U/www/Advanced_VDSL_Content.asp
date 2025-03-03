﻿<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<html xmlns:v>
<head>
<meta http-equiv="X-UA-Compatible" content="IE=Edge"/>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta HTTP-EQUIV="Pragma" CONTENT="no-cache">
<meta HTTP-EQUIV="Expires" CONTENT="-1">
<link rel="shortcut icon" href="images/favicon.png">
<link rel="icon" href="images/favicon.png">
<title><#Web_Title#> - VDSL</title>
<link rel="stylesheet" type="text/css" href="index_style.css">
<link rel="stylesheet" type="text/css" href="form_style.css">
<script type="text/javascript" src="/state.js"></script>
<script type="text/javascript" src="/general.js"></script>
<script type="text/javascript" src="/popup.js"></script>
<script type="text/javascript" src="/help.js"></script>
<script type="text/javascript" src="/validator.js"></script>
<style>
.FormTable{
	margin-top:10px;
}
</style>
<script>

<% login_state_hook(); %>
<% dsl_get_parameter(); %>

var dsl_pvc_enabled = ["0", "0", "0", "0", "0", "0", "0", "0"];

var wans_dualwan = '<% nvram_get("wans_dualwan"); %>';
<% wan_get_parameter(); %>
var original_dnsenable = parseInt('<% nvram_get("dslx_dnsenable"); %>');

if(dualWAN_support){
	var wan_type_name = wans_dualwan.split(" ")[<% nvram_get("wan_unit"); %>];
	wan_type_name = wan_type_name.toUpperCase();
	switch(wan_type_name){
		case "WAN":
			break;
		case "LAN":
			location.href = "Advanced_WAN_Content.asp";
			break;
		case "USB":
			location.href = "Advanced_Modem_Content.asp";
			break;
		default:
			break;
	}
}

// get PTM WAN setting list from hook.
// dsl_enable, dsl_proto, dsl_dot1q, dsl_vid
var DSLWANList = [ <% get_DSL_WAN_list(); %> ];

function chg_pvc_0() {

	disable_pvc_summary();
	enable_all_ctrl();
	document.form.dsl_subunit.disabled = true;
	change_dsl_unit_idx(8,0);
	change_dsl_type(document.form.dsl_proto.value);
	fixed_change_dsl_type(document.form.dsl_proto.value);
}

function chg_pvc_sub(pvc_to_chg) {
	var iptv_row = 0;
	for(var i = 1; i < DSLWANList.length; i++){
		if (DSLWANList[i][0] != "0") {
			iptv_row++;
			if (pvc_to_chg == i) break;
		}
	}

	if (pvc_to_chg != "0") {
		remove_item_from_select_bridge();
	}
	else
	{
		if (DSLWANList[0][3] == "bridge")
			remove_item_from_select_bridge();
	}
	//disable_pvc_summary();	Viz hide temp
	enable_all_ctrl();
	change_dsl_unit_idx(pvc_to_chg,iptv_row);
	change_dsl_type(document.form.dsl_proto.value);
	fixed_change_dsl_type(document.form.dsl_proto.value);
}

function remove_item_from_select_bridge() {
	if (document.form.dsl_proto.options.length == 4)
	{
		document.form.dsl_proto.options[0] = null;
	}
}

function add_pvc() {
	disable_pvc_summary();
	enable_all_ctrl();

	// find a available PVC
	var avail_pvc = 7;
	var found_pvc = false;
	for(var j = 1; j < DSLWANList.length; j++){
			if (DSLWANList[j][0] == "0") {
				found_pvc = true;
				avail_pvc = j;
				break;
			}
	}
	if (found_pvc == false) {
			// no empty pvc , return
			return;
	}

	document.form.dsl_subunit.disabled = false;
	document.form.dsl_subunit.value = avail_pvc.toString();	//sub-unit:1~7, 	0 for null
	document.form.dsl_enable.value = "1";

	free_options(document.form.dsl_proto);
	var var_item = new Option("Bridge", "bridge");
	document.form.dsl_proto.options.add(var_item);

	change_dsl_dhcp_enable();
	change_dsl_dns_enable();
	document.getElementById("dslSettings").style.display = "";

	document.getElementById("IPsetting").style.display = "none";
	document.getElementById("DNSsetting").style.display = "none";
	document.getElementById("PPPsetting").style.display = "none";
	document.getElementById("vpn_server").style.display = "none";

	change_dsl_type(document.form.dsl_proto.value);
	fixed_change_dsl_type(document.form.dsl_proto.value);
}

function add_pvc_0() {
	disable_pvc_summary();
	enable_all_ctrl();
	document.form.dsl_subunit.disabled = true;

	change_dsl_type(document.form.dsl_proto.value);
	fixed_change_dsl_type(document.form.dsl_proto.value);
}

function del_pvc_0(){
	var msg = "";
	msg += "Internet, ";
	if(DSLWANList[0][2] != 0)
		msg += "VLAN ID = "+DSLWANList[0][3].toString();
	else
		msg += "802.1Q Disable";
	msg += "\n\n";
	msg += "<#pvc_del_alert_desc#>";
	var answer = confirm (msg);
	if (answer == false)
			return;
	document.form.dsl_enable.value = "0";
	document.form.dsl_subunit.disabled = true;
	del_pvc_submit();
}

function del_pvc_sub(pvc_to_del) {
	var msg = "";
	msg += "IPTV "+pvc_to_del.toString()+", ";
	if(DSLWANList[pvc_to_del][2] != 0)
		msg += "VLAN ID = "+DSLWANList[pvc_to_del][3].toString();
	else
		msg += "802.1Q Disable";
	msg += "\n\n";
	msg += "<#pvc_del_alert_desc#>";
	var answer = confirm (msg);
	if (answer == false)
			return;
	document.form.dsl_subunit.disabled = false;
	document.form.dsl_subunit.value = pvc_to_del.toString();
	document.form.dsl_enable.value = "0";
	del_pvc_submit();
}

function showDSLWANList(){
	var addRow;
	var cell = new Array(8);	//dsl8 * dsl8.1~7
	var config_num = 0;
	for(var i = 0; i < DSLWANList.length; i++){
		if (DSLWANList[i][0] != "0") {	//enabled unit
			config_num++;
		}
	}
	if(config_num == 0){
		addRow = document.getElementById('DSL_WAN_table').insertRow(2);	//0:thead 1:th 2:the 1st rule
		for (var i = 0; i < 6; i++) {
			cell[i] = addRow.insertCell(i);
			if (i==2)
					cell[i].innerHTML = "<center>no data</center>";
			else
					cell[i].innerHTML = "&nbsp";
			cell[i].style.color = "white";
		}
		cell[6] = addRow.insertCell(6);
		cell[6].innerHTML = '<center><input class="add_btn" onclick="add_pvc_0();" value=""/></center>';
		cell[6].style.color = "white";
	}
	else{
		var row_count=0;
		// dsl_enable, dsl_proto, dsl_dot1q, dsl_vid
		for(var i = 0; i < DSLWANList.length; i++){
			if(i == 0){
					if (DSLWANList[i][0] != "0") {
							addRow = document.getElementById('DSL_WAN_table').insertRow(row_count+2);
							row_count++;
							cell[0] = addRow.insertCell(0);
							if (DSLWANList[i][2]=="1") cell[0].innerHTML = "<center><#checkbox_Yes#></center>";
							else cell[0].innerHTML = "<center><#checkbox_No#></center>";
							cell[0].style.color = "white";
							cell[1] = addRow.insertCell(1);
							cell[1].innerHTML = "<center>"+DSLWANList[i][3]+"</center>";
							cell[1].style.color = "white";
							cell[2] = addRow.insertCell(2);
							if (DSLWANList[i][1]=="pppoe") cell[2].innerHTML = "<center>PPPoE</center>";
							else if (DSLWANList[i][1]=="dhcp") cell[2].innerHTML = "<center><#BOP_ctype_title1#></center>";
							else if (DSLWANList[i][1]=="bridge") cell[2].innerHTML = "<center>Bridge</center>";
							else if (DSLWANList[i][1]=="static") cell[2].innerHTML = "<center><#BOP_ctype_title5#></center>";
							else cell[2].innerHTML = "Unknown";
							cell[2].style.color = "white";

							cell[3] = addRow.insertCell(3);
							cell[3].innerHTML = "<center><img src=images/checked.gif border=0></center>";
							cell[3].style.color = "white";
							cell[4] = addRow.insertCell(4);
							cell[4].innerHTML = '';
							cell[4].style.color = "white";

							cell[5] = addRow.insertCell(5);
							cell[5].innerHTML = '<center><span style="cursor:pointer;" onclick="chg_pvc_0();"><img src="/images/New_ui/accountedit.png"></span></center>';
							cell[5].style.color = "white";

							cell[6] = addRow.insertCell(6);
							cell[6].innerHTML = '<center><input class="remove_btn" onclick="del_pvc_0();" value=""/></center>';
							cell[6].style.color = "white";
					}
			}
			else{		//IPTV

					if (DSLWANList[i][0] != "0") {
							addRow = document.getElementById('DSL_WAN_table').insertRow(row_count+2);
							row_count++;
							cell[0] = addRow.insertCell(0);
							if (DSLWANList[i][2]=="1") cell[0].innerHTML = "<center><#checkbox_Yes#></center>";
							else cell[0].innerHTML = "<center><#checkbox_No#></center>";
							cell[0].style.color = "white";
							cell[1] = addRow.insertCell(1);
							cell[1].innerHTML = "<center>"+DSLWANList[i][3]+"</center>";
							cell[1].style.color = "white";
							cell[2] = addRow.insertCell(2);
							cell[2].innerHTML = "<center>Bridge</center>";
							cell[2].style.color = "white";
							cell[3] = addRow.insertCell(3);
							cell[3].innerHTML = "";
							cell[3].style.color = "white";
							cell[4] = addRow.insertCell(4);
							cell[4].innerHTML = '<center><img src=images/checked.gif border=0></center>';
							cell[4].style.color = "white";
							cell[5] = addRow.insertCell(5);
							//cell[5].innerHTML = '<center><span style="cursor:pointer;" onclick="chg_pvc_sub('+i.toString()+')"><img src="/images/New_ui/accountedit.png"></span></center>';
							cell[5].innerHTML = "";
							cell[5].style.color = "white";
							cell[6] = addRow.insertCell(6);
							cell[6].innerHTML = '<center><input class="remove_btn" onclick="del_pvc_sub('+i.toString()+');" value=""/></center>';
							cell[6].style.color = "white";
					}
			}
		}

		if (row_count < 8) {
			addRow = document.getElementById('DSL_WAN_table').insertRow(row_count+2);
			for (var i = 0; i < 6; i++) {
				cell[i] = addRow.insertCell(i);
				cell[i].innerHTML = "&nbsp";
				cell[i].style.color = "white";
			}
			cell[6] = addRow.insertCell(6);
			cell[6].style.color = "white";
			if(DSLWANList[0][0] != "0"){
					 cell[6].innerHTML = '<center><input class="add_btn" onclick="add_pvc();" value=""/></center>';
			}
			else{
					cell[6].innerHTML = '<center><input class="add_btn" onclick="add_pvc_0();" value=""/></center>';
			}

		}
	}
}

function initial(){
	show_menu();
	showDSLWANList();
	disable_all_ctrl();

	// WAN port
	genWANSoption();
	change_wan_unit(document.form.wan_unit);

	if(!dualWAN_support && !vdsl_support) {
		document.getElementById("WANscap").style.display = "none";
	}

	//change_dsl_type(document.form.dsl_proto.value);		//Viz add
	//fixed_change_dsl_type(document.form.dsl_proto.value);		//Viz add
}

function change_wan_unit(obj){
	if(!dualWAN_support) return;

	if(obj.options[obj.selectedIndex].text == "DSL"){
		if(document.form.dsltmp_transmode){
			document.form.dsltmp_transmode.style.display = "";
			//change_dsl_transmode(document.form.dsltmp_transmode);
		}

		if(document.form.dsltmp_transmode.value == document.form.dslx_transmode.value)
			document.getElementById("active_dslmode").innerHTML = "( Active )";
		else
			document.getElementById("active_dslmode").innerHTML = "( Not Active )";

	}else if(document.form.dsltmp_transmode){
		document.form.dsltmp_transmode.style.display = "none";
	}

	if(obj.options[obj.selectedIndex].text == "WAN" 
		|| obj.options[obj.selectedIndex].text == "Ethernet LAN"
		|| obj.options[obj.selectedIndex].text == "Ethernet WAN"){
		document.form.current_page.value = "Advanced_WAN_Content.asp";
	}
	else if(obj.options[obj.selectedIndex].text == "USB") {
		document.form.current_page.value = "Advanced_Modem_Content.asp";
	}
	else if(obj.options[obj.selectedIndex].text == "DSL" && document.form.dsltmp_transmode.value == "atm"){
		document.form.current_page.value = "Advanced_DSL_Content.asp";
	}else{
		return false;
	}

	FormActions("apply.cgi", "change_wan_unit", "", "");
	document.form.target = "";
	document.form.submit();
}

function change_dsl_transmode(obj){
	if(obj.value == "atm"){
		document.form.current_page.value = "Advanced_DSL_Content.asp";
	}else{ // ptm
		return false;
	}
	FormActions("apply.cgi", "change_dslx_transmode", "", "");
	document.form.target = "";
	document.form.submit();
}

function genWANSoption(){
	if(!dualWAN_support) return;

	for(i=0; i<wans_dualwan.split(" ").length; i++){
		var wans_dualwan_NAME = wans_dualwan.split(" ")[i].toUpperCase();
		var wans_dualwan_NAME = wans_dualwan.split(" ")[i].toUpperCase();
		//MODELDEP: DSL-N55U, DSL-N55U-B, DSL-AC68U, DSL-AC68R
		if(wans_dualwan_NAME == "LAN" && 
				(productid == "DSL-N55U" || productid == "DSL-N55U-B" || productid == "DSL-AC68U" || productid == "DSL-AC68R")) 
				wans_dualwan_NAME = "Ethernet WAN";
		else if(wans_dualwan_NAME == "LAN")
				wans_dualwan_NAME = "Ethernet LAN";
		if(wans_dualwan_NAME != "NONE")
			document.form.wan_unit.options[i] = new Option(wans_dualwan_NAME, i);
	}
	document.form.wan_unit.selectedIndex = '<% nvram_get("wan_unit"); %>';
}

function change_dsl_unit_idx(idx,iptv_row){
	// reset to old values
	document.form.dsl_unit.value = "8";
	document.form.dsl_subunit.value = iptv_row;
	document.form.dsl_enable.value = DSLWANList[iptv_row][0];
	document.form.dsl_proto.value = DSLWANList[iptv_row][1];
	document.form.dsl_dot1q.value = DSLWANList[iptv_row][2];
	document.form.dsl_vid.value = DSLWANList[iptv_row][3];
	document.form.dsl_dot1p.value = DSLWANList[iptv_row][4];

	change_dsl_dhcp_enable();
	change_dsl_dns_enable();
	document.getElementById("dslSettings").style.display = "";
	if (document.form.dsl_proto.value != "bridge") {
		document.getElementById("IPsetting").style.display = "";
		document.getElementById("DNSsetting").style.display = "";
		document.getElementById("PPPsetting").style.display = "";
		document.getElementById("vpn_server").style.display = "";
	}
	else {
		document.getElementById("IPsetting").style.display = "none";
		document.getElementById("DNSsetting").style.display = "none";
		document.getElementById("PPPsetting").style.display = "none";
		document.getElementById("vpn_server").style.display = "none";
	}
}

function del_pvc_submit(){
	showLoading();
	document.form.submit();
}

function exit_to_main(){
	enable_pvc_summary();
	disable_all_ctrl();
}

function applyRule(){
	if(validForm()){

		if (document.form.dsl_proto.value == "bridge") {
			document.getElementById('bridgePPPoE_relay').innerHTML = '<input type="hidden" name="fw_pt_pppoerelay" value="1"> ';
			document.form.action_script.value = "reboot";
			document.form.action_wait.value = "<% get_default_reboot_time(); %>";
			if(document.form.dsl_dot1q.value == "1")
				document.form.dslx_rmvlan.value = "1";
		}

		if (document.form.dsl_proto.value == "static"){
			document.form.dslx_DHCPClient.value = 0;
		}else if(document.form.dslx_DHCPClient_x){
			if(document.form.dslx_DHCPClient_x[0].checked == 1)
					document.form.dslx_DHCPClient.value = 1;
			else
					document.form.dslx_DHCPClient.value = 0;
		}

		document.form.wan_enable.value = document.form.dslx_link_enable.value;
		document.form.dsl_enable.value = "1";
		if(document.form.dslx_transmode.value != document.form.dsltmp_transmode.value) {
			document.form.action_script.value = "restart_dsl_setting;".concat(document.form.action_script.value);
			document.form.dslx_transmode.value = document.form.dsltmp_transmode.value;
		}
		showLoading();
		document.form.submit();
	}
}
/* Viz replace it
function applyRule(){
	var vpi_num = document.form.dsl_vpi.value;
	var vci_num = document.form.dsl_vci.value;

	for(var i = 0; i < DSLWANList.length; i++){
		if (i!=document.form.dsl_unit.value) {
			if (dsl_pvc_enabled[i] != "0") {
				if (vpi_num == DSLWANList[i][1] && vci_num == DSLWANList[i][2]) {
					alert("<#same_vpi_vci#>");
					return;
				}
			}
		}
	}

	if(document.form.dslx_dnsenable[1].checked == true && document.form.dsl_proto.value != "mer" && document.form.dslx_dns1.value == "" && document.form.dslx_dns2.value == "") {
		alert("<#dns_server_no_set#>");
		return;
	}

	if(validForm()){
		showLoading();

		inputCtrl(document.form.dslx_DHCPClient[0], 1);
		inputCtrl(document.form.dslx_DHCPClient[1], 1);
		if(!document.form.dslx_DHCPClient[0].checked){
			inputCtrl(document.form.dslx_ipaddr, 1);
			inputCtrl(document.form.dslx_netmask, 1);
			inputCtrl(document.form.dslx_gateway, 1);
		}

		inputCtrl(document.form.dslx_dnsenable[0], 1);
		inputCtrl(document.form.dslx_dnsenable[1], 1);
		if(!document.form.dslx_dnsenable[0].checked){
			inputCtrl(document.form.dslx_dns1, 1);
			inputCtrl(document.form.dslx_dns1, 1);
		}

		if (document.form.dsl_unit.value=='0' && document.form.dsl_enable.value=='1') {
			document.form.wan_enable.value = document.form.dslx_link_enable.value;
			document.form.wan_unit.value = '0';
			document.form.wan_enable.disabled = false;
			document.form.wan_unit.disabled = false;
		}

		if (document.form.dsl_unit.value == 0 && document.form.dsl_proto.value == "bridge")
			document.getElementById('bridgePPPoE_relay').innerHTML = '<input type="hidden" name="fw_pt_pppoerelay" value="1"> ';

		inputCtrl(document.form.dsl_pcr, 1);
		inputCtrl(document.form.dsl_scr, 1);
		inputCtrl(document.form.dsl_mbs, 1);

		if (document.form.dsl_proto.value == "bridge") {
			document.form.action_script.value = "reboot";
			document.form.action_wait.value = "<% get_default_reboot_time(); %>";
		}

		document.form.dslx_transmode.value = document.form.dsltmp_transmode.value;

		document.form.submit();
	}
}*/

// test if WAN IP & Gateway & DNS IP is a valid IP
// DNS IP allows to input nothing
function valid_IP(obj_name, obj_flag){
		// A : 1.0.0.0~126.255.255.255
		// B : 127.0.0.0~127.255.255.255 (forbidden)
		// C : 128.0.0.0~255.255.255.254
		var A_class_start = inet_network("1.0.0.0");
		var A_class_end = inet_network("126.255.255.255");
		var B_class_start = inet_network("127.0.0.0");
		var B_class_end = inet_network("127.255.255.255");
		var C_class_start = inet_network("128.0.0.0");
		var C_class_end = inet_network("255.255.255.255");

		var ip_obj = obj_name;
		var ip_num = inet_network(ip_obj.value);

		if(obj_flag == "DNS" && ip_num == -1){ //DNS allows to input nothing
			return true;
		}

		if(obj_flag == "GW" && ip_num == -1){ //GW allows to input nothing
			return true;
		}

		if(ip_num > A_class_start && ip_num < A_class_end)
			return true;
		else if(ip_num > B_class_start && ip_num < B_class_end){
			alert(ip_obj.value+" <#JS_validip#>");
			ip_obj.focus();
			ip_obj.select();
			return false;
		}
		else if(ip_num > C_class_start && ip_num < C_class_end)
			return true;
		else{
			alert(ip_obj.value+" <#JS_validip#>");
			ip_obj.focus();
			ip_obj.select();
			return false;
		}
}

function validForm(){
	if(!document.form.dslx_DHCPClient_x[0].checked){// Set IP address by userself
		if(!valid_IP(document.form.dslx_ipaddr, "")) return false;  //WAN IP
		if(!valid_IP(document.form.dslx_gateway, "GW"))return false;  //Gateway IP

		if(document.form.dslx_gateway.value == document.form.dslx_ipaddr.value){
			alert("<#IPConnection_warning_WANIPEQUALGatewayIP#>");
			return false;
		}

		// test if netmask is valid.
		var default_netmask = "";
		var wrong_netmask = 0;
		var netmask_obj = document.form.dslx_netmask;
		var netmask_num = inet_network(netmask_obj.value);

		if(netmask_num==0){
			var netmask_reverse_num = 0;		//Viz 2011.07 : Let netmask 0.0.0.0 pass
		}else{
		var netmask_reverse_num = ~netmask_num;
		}

		if(netmask_num < 0) wrong_netmask = 1;

		var test_num = netmask_reverse_num;
		while(test_num != 0){
			if((test_num+1)%2 == 0)
				test_num = (test_num+1)/2-1;
			else{
				wrong_netmask = 1;
				break;
			}
		}
		if(wrong_netmask == 1){
			alert(netmask_obj.value+" <#JS_validip#>");
			netmask_obj.value = default_netmask;
			netmask_obj.focus();
			netmask_obj.select();
			return false;
		}
	}

	if(!document.form.dslx_dnsenable[0].checked){
		if(!valid_IP(document.form.dslx_dns1, "DNS")) return false;  //DNS1
		if(!valid_IP(document.form.dslx_dns2, "DNS")) return false;  //DNS2
	}

	if(document.form.dsl_proto.value == "pppoe"
			|| document.form.dsl_proto.value == "pppoa"
			){
		if(!validator.string(document.form.dslx_pppoe_username)
				|| !validator.string(document.form.dslx_pppoe_passwd)
				)
			return false;

		if(!validator.numberRange(document.form.dslx_pppoe_idletime, 0, 4294967295))
			return false;
	}

	if(document.form.dsl_proto.value == "pppoe"){
		if(!validator.numberRange(document.form.dslx_pppoe_mtu, 128, 1492))
			return false;

		if(!validator.string(document.form.dslx_pppoe_service)
				|| !validator.string(document.form.dslx_pppoe_ac))
			return false;
	}

	if(document.form.dslx_hwaddr.value.length > 0)
		if(!check_macaddr(document.form.dslx_hwaddr, check_hwaddr_flag(document.form.dslx_hwaddr))){
				document.form.dslx_hwaddr.select();
				document.form.dslx_hwaddr.focus();
				return false;
		}

	return true;
}

function done_validating(action){
	refreshpage();
}

function disable_pvc_summary() {
	document.getElementById("DSL_WAN_table").style.display = "none";
}

function enable_pvc_summary() {
	document.getElementById("DSL_WAN_table").style.display = "";
}

function disable_all_ctrl() {
	document.getElementById("desc_default").style.display = "";
	document.getElementById("desc_edit").style.display = "none";
	document.getElementById("dslSettings").style.display = "none";
	document.getElementById("PPPsetting").style.display = "none";
	document.getElementById("DNSsetting").style.display = "none";
	document.getElementById("dot1q_setting").style.display = "none";
	document.getElementById("IPsetting").style.display = "none";
	document.getElementById("vpn_server").style.display = "none";
	document.getElementById("btn_apply").style.display = "none";
}

function enable_all_ctrl() {
	document.getElementById("desc_default").style.display = "none";
	document.getElementById("desc_edit").style.display = "";
	document.getElementById("dslSettings").style.display = "";
	document.getElementById("PPPsetting").style.display = "";
	document.getElementById("DNSsetting").style.display = "";
	document.getElementById("dot1q_setting").style.display = "";
	document.getElementById("IPsetting").style.display = "";
	document.getElementById("vpn_server").style.display = "";
	document.getElementById("btn_apply").style.display = "";
}

function change_dsl_type(dsl_type){
	change_dsl_dhcp_enable();
	change_dsl_dns_enable();

	if(dsl_type == "pppoe" || dsl_type == "pppoa"){
		inputCtrl(document.form.dslx_dnsenable[0], 1);
		inputCtrl(document.form.dslx_dnsenable[1], 1);

		inputCtrl(document.form.dslx_pppoe_username, 1);
		inputCtrl(document.form.dslx_pppoe_passwd, 1);
		inputCtrl(document.form.dslx_pppoe_auth, 1);
		inputCtrl(document.form.dslx_pppoe_idletime, 1);
		inputCtrl(document.form.dslx_pppoe_mtu, 1);
		inputCtrl(document.form.dslx_pppoe_service, 1);
		inputCtrl(document.form.dslx_pppoe_ac, 1);

		// 2008.03 James. patch for Oleg's patch. {
		inputCtrl(document.form.dslx_pppoe_options, 1);
		// 2008.03 James. patch for Oleg's patch. }
		showhide("PPPsetting",1);
	}
	else if(dsl_type == "static"){
		inputCtrl(document.form.dslx_dnsenable[0], 0);
		inputCtrl(document.form.dslx_dnsenable[1], 0);

		inputCtrl(document.form.dslx_pppoe_username, 0);
		inputCtrl(document.form.dslx_pppoe_passwd, 0);
		inputCtrl(document.form.dslx_pppoe_auth, 0);
		inputCtrl(document.form.dslx_pppoe_idletime, 0);
		inputCtrl(document.form.dslx_pppoe_mtu, 0);
		inputCtrl(document.form.dslx_pppoe_service, 0);
		inputCtrl(document.form.dslx_pppoe_ac, 0);
		// 2008.03 James. patch for Oleg's patch. {
		inputCtrl(document.form.dslx_pppoe_options, 0);
		// 2008.03 James. patch for Oleg's patch. }
		showhide("PPPsetting",0);
	}
	else if(dsl_type == "dhcp"){
		inputCtrl(document.form.dslx_dnsenable[0], 1);
		inputCtrl(document.form.dslx_dnsenable[1], 1);

		inputCtrl(document.form.dslx_pppoe_username, 0);
		inputCtrl(document.form.dslx_pppoe_passwd, 0);
		inputCtrl(document.form.dslx_pppoe_auth, 0);
		inputCtrl(document.form.dslx_pppoe_idletime, 0);
		inputCtrl(document.form.dslx_pppoe_mtu, 0);
		inputCtrl(document.form.dslx_pppoe_service, 0);
		inputCtrl(document.form.dslx_pppoe_ac, 0);

		// 2008.03 James. patch for Oleg's patch. {
		inputCtrl(document.form.dslx_pppoe_options, 0);
		// 2008.03 James. patch for Oleg's patch. }
		showhide("PPPsetting",0);
	}
	else if(dsl_type == "bridge") {
		inputCtrl(document.form.dslx_dnsenable[0], 0);
		inputCtrl(document.form.dslx_dnsenable[1], 0);
		inputCtrl(document.form.dslx_pppoe_username, 0);
		inputCtrl(document.form.dslx_pppoe_passwd, 0);
		inputCtrl(document.form.dslx_pppoe_auth, 0);
		inputCtrl(document.form.dslx_pppoe_idletime, 0);
		inputCtrl(document.form.dslx_pppoe_mtu, 0);
		inputCtrl(document.form.dslx_pppoe_service, 0);
		inputCtrl(document.form.dslx_pppoe_ac, 0);

		// 2008.03 James. patch for Oleg's patch. {
		inputCtrl(document.form.dslx_pppoe_options, 0);
		// 2008.03 James. patch for Oleg's patch. }
		showhide("PPPsetting",0);
	}
	else {
		alert("error");
	}
}


function fixed_change_dsl_type(dsl_type){
	if(!document.form.dslx_DHCPClient_x[0].checked){
		if(document.form.dslx_ipaddr.value.length == 0)
			document.form.dslx_ipaddr.focus();
		else if(document.form.dslx_netmask.value.length == 0)
			document.form.dslx_netmask.focus();
		else if(document.form.dslx_gateway.value.length == 0)
			document.form.dslx_gateway.focus();
	}

	if(dsl_type == "pppoe" || dsl_type == "pppoa"){
		document.form.dslx_dnsenable[0].checked = original_dnsenable;
		document.form.dslx_dnsenable[1].checked = !original_dnsenable;
		change_common_radio(document.form.dslx_dnsenable, 'IPConnection', 'dslx_dnsenable', 0);
		inputCtrl(document.form.dslx_dns1, !original_dnsenable);
		inputCtrl(document.form.dslx_dns2, !original_dnsenable);
		inputCtrl(document.form.dslx_hwaddr, 1);
		inputCtrl(document.form.dslx_link_enable[0], 1);
		inputCtrl(document.form.dslx_link_enable[1], 1);
		inputCtrl(document.form.dslx_nat[0], 1);
		inputCtrl(document.form.dslx_nat[1], 1);
		inputCtrl(document.form.dslx_upnp_enable[0], 1);
		inputCtrl(document.form.dslx_upnp_enable[1], 1);
		showhide("IPsetting",1);
		showhide("DNSsetting",1);
		showhide("vpn_server",1);
	}
	//else if(dsl_type == "ipoa"){
	else if(dsl_type == "static"){
		document.form.dslx_dnsenable[0].checked = 0;
		document.form.dslx_dnsenable[1].checked = 1;
		change_common_radio(document.form.dslx_dnsenable, 'IPConnection', 'dslx_dnsenable', 0);
		inputCtrl(document.form.dslx_hwaddr, 1);
		inputCtrl(document.form.dslx_link_enable[0], 1);
		inputCtrl(document.form.dslx_link_enable[1], 1);
		inputCtrl(document.form.dslx_nat[0], 1);
		inputCtrl(document.form.dslx_nat[1], 1);
		inputCtrl(document.form.dslx_upnp_enable[0], 1);
		inputCtrl(document.form.dslx_upnp_enable[1], 1);
		showhide("IPsetting",1);
		showhide("DNSsetting",1);
		showhide("vpn_server",1);
	}
	// Viz mod else if(dsl_type == "mer"){
	else if(dsl_type == "dhcp"){
		inputCtrl(document.form.dslx_DHCPClient_x[0], 0);
		inputCtrl(document.form.dslx_DHCPClient_x[1], 0);
		document.getElementById("IPsetting").style.display = "none";
		inputCtrl(document.form.dslx_hwaddr, 1);
		inputCtrl(document.form.dslx_link_enable[0], 1);
		inputCtrl(document.form.dslx_link_enable[1], 1);
		inputCtrl(document.form.dslx_nat[0], 1);
		inputCtrl(document.form.dslx_nat[1], 1);
		inputCtrl(document.form.dslx_upnp_enable[0], 1);
		inputCtrl(document.form.dslx_upnp_enable[1], 1);
		showhide("DNSsetting",1);
		showhide("vpn_server",1);
	}
	else if(dsl_type == "bridge"){
		document.form.dslx_dnsenable[0].checked = 1;
		document.form.dslx_dnsenable[1].checked = 0;
		change_common_radio(document.form.dslx_dnsenable, 'IPConnection', 'dslx_dnsenable', 0);

		inputCtrl(document.form.dslx_dns1, 0);
		inputCtrl(document.form.dslx_dns2, 0);
		inputCtrl(document.form.dslx_hwaddr, 0);
		if(document.form.dsl_subunit.value != 0){
			inputCtrl(document.form.dslx_link_enable[0], 0);
			inputCtrl(document.form.dslx_link_enable[1], 0);
			inputCtrl(document.form.dslx_upnp_enable[0], 0);
			inputCtrl(document.form.dslx_upnp_enable[1], 0);
		}
		else{
			inputCtrl(document.form.dslx_link_enable[0], 1);
			inputCtrl(document.form.dslx_link_enable[1], 1);
			inputCtrl(document.form.dslx_upnp_enable[0], 1);
			inputCtrl(document.form.dslx_upnp_enable[1], 1);
		}
		inputCtrl(document.form.dslx_nat[0], 0);
		inputCtrl(document.form.dslx_nat[1], 0);
		showhide("DNSsetting",0);
		showhide("vpn_server",0);
	}
	else {
		alert("error");
	}
}

function change_dsl_dns_enable(){
	var dsl_type = document.form.dsl_proto.value;

	if(dsl_type == "pppoe" || dsl_type == "pppoa" || dsl_type == "dhcp"){
		inputCtrl(document.form.dslx_dnsenable[0], 1);
		inputCtrl(document.form.dslx_dnsenable[1], 1);

		var wan_dnsenable = document.form.dslx_dnsenable[0].checked;
		//var wan_dnsenable = true;
		//var wan_dnsenable = false;

		inputCtrl(document.form.dslx_dns1, !wan_dnsenable);
		inputCtrl(document.form.dslx_dns2, !wan_dnsenable);
	}
	else if(dsl_type == "static"){
	// value fix
		inputCtrl(document.form.dslx_dnsenable[0], 0);
		inputCtrl(document.form.dslx_dnsenable[1], 0);

		inputCtrl(document.form.dslx_dns1, 1);
		inputCtrl(document.form.dslx_dns2, 1);
	}
	else{	// dsl_type == bridge
		inputCtrl(document.form.dslx_dnsenable[0], 0);
		inputCtrl(document.form.dslx_dnsenable[1], 0);

		inputCtrl(document.form.dslx_dns1, 0);
		inputCtrl(document.form.dslx_dns2, 0);
	}

/*
	if(document.form.dslx_DHCPClient[0].checked){
		inputCtrl(document.form.dslx_dnsenable[0], 1);
		inputCtrl(document.form.dslx_dnsenable[1], 1);
	}
	else{		// dhcp NO
		document.form.dslx_dnsenable[0].checked = 0;
		document.form.dslx_dnsenable[1].checked = 1;
		change_common_radio(document.form.dslx_dnsenable, 'IPConnection', 'dslx_dnsenable', 0);

		inputCtrl(document.form.dslx_dnsenable[0], 1);
		inputCtrl(document.form.dslx_dnsenable[1], 1);
	}
*/
}

function change_dsl_dhcp_enable(){
	var dsl_type = document.form.dsl_proto.value;

	if(dsl_type == "pppoe" || dsl_type == "pppoa"){
		inputCtrl(document.form.dslx_DHCPClient_x[0], 1);
		inputCtrl(document.form.dslx_DHCPClient_x[1], 1);

		var wan_dhcpenable = document.form.dslx_DHCPClient_x[0].checked;

		inputCtrl(document.form.dslx_ipaddr, !wan_dhcpenable);
		inputCtrl(document.form.dslx_netmask, !wan_dhcpenable);
		inputCtrl(document.form.dslx_gateway, !wan_dhcpenable);
		document.getElementById("IPsetting").style.display = "";

		if(document.form.dslx_DHCPClient_x[1].checked)
		{
			inputCtrl(document.form.dslx_dns1, 1);
			inputCtrl(document.form.dslx_dns2, 1);
		}
	}
	else if(dsl_type == "dhcp"){	//Viz modify this case
		document.form.dslx_DHCPClient_x[0].checked = 1;

		inputCtrl(document.form.dslx_ipaddr, 0);
		inputCtrl(document.form.dslx_netmask, 0);
		inputCtrl(document.form.dslx_gateway, 0);
		document.getElementById("IPsetting").style.display = "none";

		if(document.form.dslx_dnsenable[1].checked)
		{
			inputCtrl(document.form.dslx_dns1, 1);
			inputCtrl(document.form.dslx_dns2, 1);
		}
	}
	else if(dsl_type == "static"){
		document.form.dslx_DHCPClient_x[0].checked = 0;
		document.form.dslx_DHCPClient_x[1].checked = 1;
		inputCtrl(document.form.dslx_DHCPClient_x[0], 0);
		inputCtrl(document.form.dslx_DHCPClient_x[1], 0);
		inputCtrl(document.form.dslx_ipaddr, 1);
		inputCtrl(document.form.dslx_netmask, 1);
		inputCtrl(document.form.dslx_gateway, 1);
		document.getElementById("IPsetting").style.display = "";
	}
	else{	// dsl_type == bridge
		document.form.dslx_DHCPClient_x[0].checked = 1;
		document.form.dslx_DHCPClient_x[1].checked = 0;
		inputCtrl(document.form.dslx_DHCPClient_x[0], 0);
		inputCtrl(document.form.dslx_DHCPClient_x[1], 0);
		inputCtrl(document.form.dslx_ipaddr, 0);
		inputCtrl(document.form.dslx_netmask, 0);
		inputCtrl(document.form.dslx_gateway, 0);
		document.getElementById("IPsetting").style.display = "none";
	}

	if(document.form.dslx_DHCPClient_x[0].checked){
		inputCtrl(document.form.dslx_dnsenable[0], 1);
		inputCtrl(document.form.dslx_dnsenable[1], 1);
	}
	else{		// dhcp NO
		document.form.dslx_dnsenable[0].checked = 0;
		document.form.dslx_dnsenable[1].checked = 1;
		change_common_radio(document.form.dslx_dnsenable, 'IPConnection', 'dslx_dnsenable', 0);

		inputCtrl(document.form.dslx_dnsenable[0], 0);
		inputCtrl(document.form.dslx_dnsenable[1], 0);
	}
}
/*
function changeDSLunit(){
	if(document.form.dsl_unit.value == 0){
		document.getElementById("PPPsetting").style.display = "";
		document.getElementById("DNSsetting").style.display = "";
		document.getElementById("IPsetting").style.display = "";
		document.getElementById("vpn_server").style.display = "";
		inputCtrl(document.form.dsl_enable, 0);
	}
	else{
		document.getElementById("PPPsetting").style.display = "none";
		document.getElementById("DNSsetting").style.display = "none";
		document.getElementById("IPsetting").style.display = "none";
		document.getElementById("vpn_server").style.display = "none";
		inputCtrl(document.form.dsl_enable, 1);
	}
}
*/
function showMAC(){
	var tempMAC = "";
	document.form.dslx_hwaddr.value = login_mac_str();
}

function check_macaddr(obj,flag){ //control hint of input mac address
	if(flag == 1){
		var childsel=document.createElement("div");
		childsel.setAttribute("id","check_mac");
		childsel.style.color="#FFCC00";
		obj.parentNode.appendChild(childsel);
		document.getElementById("check_mac").innerHTML="<#LANHostConfig_ManualDHCPMacaddr_itemdesc#>";
		return false;
	}else if(flag ==2){
		var childsel=document.createElement("div");
		childsel.setAttribute("id","check_mac");
		childsel.style.color="#FFCC00";
		obj.parentNode.appendChild(childsel);
		document.getElementById("check_mac").innerHTML="<#IPConnection_x_illegal_mac#>";
		return false;
	}else{
		document.getElementById("check_mac") ? document.getElementById("check_mac").style.display="none" : true;
		return true;
	}
}

/* password item show or not */
function pass_checked(obj){
	switchType(obj, document.form.show_pass_1.checked, true);
}

</script>
</head>

<body onload="initial();" onunLoad="return unload_body();">
<div id="TopBanner"></div>
<div id="Loading" class="popup_bg"></div>
<iframe name="hidden_frame" id="hidden_frame" src="" width="0" height="0" frameborder="0"></iframe>
<form method="post" name="iptvForm" action="/start_apply.htm" target="hidden_frame">
<input type="hidden" name="productid" value="<% nvram_get("productid"); %>">
<input type="hidden" name="current_page" value="Advanced_DSL_Content.asp">
<input type="hidden" name="next_page" value="Advanced_DSL_Content.asp">
<input type="hidden" name="group_id" value="">
<input type="hidden" name="modified" value="0">
<input type="hidden" name="action_mode" value="apply">
<input type="hidden" name="action_script" value="restart_dslwan_if 0">
<input type="hidden" name="action_wait" value="5">
<input type="hidden" name="preferred_lang" id="preferred_lang" value="<% nvram_get("preferred_lang"); %>">
<input type="hidden" name="dsl_unit" value="8" />
<input type="hidden" name="dsl_subunit" value="" />
<input type="hidden" name="dsl_enable" value="" />
<input type="hidden" name="dsl_proto" value="" />
<input type="hidden" name="dsl_dot1q" value="" />
<input type="hidden" name="dsl_vid" value="" />
</form>
<form method="post" name="form" id="ruleForm" action="/start_apply.htm" target="hidden_frame">
<input type="hidden" name="productid" value="<% nvram_get("productid"); %>">
<input type="hidden" name="current_page" value="Advanced_DSL_Content.asp">
<input type="hidden" name="next_page" value="Advanced_DSL_Content.asp">
<input type="hidden" name="group_id" value="">
<input type="hidden" name="modified" value="0">
<input type="hidden" name="action_mode" value="apply">
<input type="hidden" name="action_script" value="restart_dslwan_if 0">
<input type="hidden" name="action_wait" value="5">
<input type="hidden" name="first_time" value="">
<input type="hidden" name="preferred_lang" id="preferred_lang" value="<% nvram_get("preferred_lang"); %>">
<input type="hidden" name="firmver" value="<% nvram_get("firmver"); %>">
<input type="hidden" name="lan_ipaddr" value="<% nvram_get("lan_ipaddr"); %>" />
<input type="hidden" name="lan_netmask" value="<% nvram_get("lan_netmask"); %>" />
<input type="hidden" name="dsl_unit" value="8" />
<input type="hidden" name="dsl_subunit" value="" />
<input type="hidden" name="dsl_enable" value="" />
<input type="hidden" name="dslx_transmode" value="<% nvram_get("dslx_transmode"); %>">
<input type="hidden" name="dslx_DHCPClient" value="<% nvram_get("dslx_DHCPClient"); %>">
<input type="hidden" name="dslx_rmvlan" value="<% nvram_get("dslx_rmvlan"); %>">
<input type="hidden" name="wan_enable" value="" disabled>
<!--input type="hidden" name="wan_unit" value="" disabled-->
<span id="bridgePPPoE_relay"></span>
<table class="content" align="center" cellpadding="0" cellspacing="0">
	<tr>
		<td width="17">&nbsp;</td>
	<!--=====Beginning of Main Menu=====-->
		<td valign="top" width="202">
		  <div id="mainMenu"></div>
		  <div id="subMenu"></div>
		</td>

		<td height="430" valign="top">
			<div id="tabMenu" class="submenuBlock"></div>
		  <!--===================================Beginning of Main Content===========================================-->
			<table width="98%" border="0" align="left" cellpadding="0" cellspacing="0">
				<tr>
					<td valign="top">
						<table width="760px" border="0" cellpadding="5" cellspacing="0" class="FormTitle" id="FormTitle">
							<tbody>
								<tr>
								<td bgcolor="#4D595D" valign="top">
									<div>&nbsp;</div>
									<div class="formfonttitle"><#menu5_3#> - <#menu5_3_1#></div>
									<div style="margin-left:5px;margin-top:10px;margin-bottom:10px"><img src="/images/New_ui/export/line_export.png"></div>
									<div id="desc_default" class="formfontdesc"><#dsl_wan_page_desc#></div>
									<div id="desc_edit" class="formfontdesc"><#Layer3Forwarding_x_ConnectionType_sectiondesc#></div>

									<table id="WANscap" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
										<thead>
										<tr>
											<td colspan="2"><#wan_index#></td>
										</tr>
										</thead>
										<tr>
											<th><#wan_type#></th>
											<td align="left">
												<select id="wan_unit" class="input_option" name="wan_unit" onchange="change_wan_unit(this);"></select>
												<select id="dsltmp_transmode" name="dsltmp_transmode" class="input_option" style="margin-left:7px;" onChange="change_dsl_transmode(this);">
													<option value="atm" <% nvram_match("dsltmp_transmode", "atm", "selected"); %>>ADSL WAN (ATM)</option>
													<option value="ptm" <% nvram_match("dsltmp_transmode", "ptm", "selected"); %>>VDSL WAN (PTM)</option>
												</select>
												<span id="active_dslmode"></span>
											</td>
										</tr>
									</table>

									<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="DSL_WAN_table">
										<thead>
										<tr>
											<td colspan="7"><#PVC_summary#></td>
										</tr>
										</thead>
											<tr>
												<th style="width:20%;"><center>802.1Q Enable</center></th>
												<th style="width:20%;"><center>VLAN ID</center></th>
												<th style="width:20%;"><center><#IPConnection_VServerProto_itemname#></center></th>
												<th style="width:10%;"><center><#Internet#></center></th>
												<th style="width:10%;"><center><#menu_dsl_iptv#></center></th>
												<th style="width:10%;"><center><#PVC_edit#></center></th>
												<th style="width:10%;"><center><#list_add_delete#></center></th>
											</tr>
									</table>

									<table id="dslSettings" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
										<thead>
										<tr>
											<td colspan="2"><#pvccfg_PVC_Setting#></td>
										</tr>
										</thead>
										<tr>
											<th><#Layer3Forwarding_x_ConnectionType_itemname#></th>
											<td align="left">
												<select class="input_option" name="dsl_proto" onchange="change_dsl_type(this.value);fixed_change_dsl_type(this.value);">
													<option value="dhcp" <% nvram_match("dsl_proto", "dhcp", "selected"); %>><#BOP_ctype_title1#></option>
													<option value="static" <% nvram_match("dsl_proto", "static", "selected"); %>><#BOP_ctype_title5#></option>
													<option value="pppoe" <% nvram_match("dsl_proto", "pppoe", "selected"); %>>PPPoE</option>
													<option value="bridge" <% nvram_match("dsl_proto", "bridge", "selected"); %>>Bridge</option>
												</select>
											</td>
										</tr>
										<tr>
											<th><#Enable_WAN#></th>
											<td>
												<input type="radio" name="dslx_link_enable" class="input" value="1" <% nvram_match("dslx_link_enable", "1", "checked"); %>><#checkbox_Yes#>
												<input type="radio" name="dslx_link_enable" class="input" value="0" <% nvram_match("dslx_link_enable", "0", "checked"); %>><#checkbox_No#>
											</td>
										</tr>
										<tr>
											<th><a class="hintstyle" href="javascript:void(0);" onClick="openHint(7,22);"><#Enable_NAT#></a></th>
											<td>
												<input type="radio" name="dslx_nat" class="input" value="1" <% nvram_match("dslx_nat", "1", "checked"); %>><#checkbox_Yes#>
												<input type="radio" name="dslx_nat" class="input" value="0" <% nvram_match("dslx_nat", "0", "checked"); %>><#checkbox_No#>
											</td>
										</tr>
										<tr>
											<th><a class="hintstyle" href="javascript:void(0);" onClick="openHint(7,23);"><#BasicConfig_EnableMediaServer_itemname#></a></th>
											<td>
												<input type="radio" name="dslx_upnp_enable" class="input" value="1" onclick="return change_common_radio(this, 'LANHostConfig', 'dslx_upnp_enable', '1')" <% nvram_match("dslx_upnp_enable", "1", "checked"); %>><#checkbox_Yes#>
												<input type="radio" name="dslx_upnp_enable" class="input" value="0" onclick="return change_common_radio(this, 'LANHostConfig', 'dslx_upnp_enable', '0')" <% nvram_match("dslx_upnp_enable", "0", "checked"); %>><#checkbox_No#>
											</td>
										</tr>
									</table>

									<table id="dot1q_setting" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
										<thead>
										<tr>
											<td colspan="2">802.1Q</td>
										</tr>
										</thead>
										<tr>
											<th><#WLANConfig11b_WirelessCtrl_button1name#></th>
											<td>
												<input type="radio" name="dsl_dot1q" class="input" value="1" onclick="change_dsl_dhcp_enable();" <% nvram_match("dsl_dot1q", "1", "checked"); %>><#checkbox_Yes#>
												<input type="radio" name="dsl_dot1q" class="input" value="0" onclick="change_dsl_dhcp_enable();" <% nvram_match("dsl_dot1q", "0", "checked"); %>><#checkbox_No#>
											</td>
										</tr>
										<tr>
											<th>VLAN ID</th>
											<td>
												<input type="text" name="dsl_vid" maxlength="4" class="input_6_table" value="<% nvram_get("dsl_vid"); %>" onKeyPress="return validator.isNumber(this,event);" autocorrect="off" autocapitalize="off"> 0 - 4095
											</td>
										</tr>
										<tr>
											<th>802.1P</th>
											<td>
												<input type="text" name="dsl_dot1p" maxlength="4" class="input_6_table" value="<% nvram_get("dsl_dot1p"); %>" onKeyPress="return validator.isNumber(this,event);"> 0 - 7
											</td>
										</tr>
									<table>

									<table id="IPsetting" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
										<thead>
										<tr>
											<td colspan="2"><#IPConnection_ExternalIPAddress_sectionname#></td>
										</tr>
										</thead>

										<tr>
											<th><#Layer3Forwarding_x_DHCPClient_itemname#></th>
											<td>
												<input type="radio" name="dslx_DHCPClient_x" class="input" value="1" onclick="change_dsl_dhcp_enable();" <% nvram_match("dslx_DHCPClient", "1", "checked"); %>><#checkbox_Yes#>
												<input type="radio" name="dslx_DHCPClient_x" class="input" value="0" onclick="change_dsl_dhcp_enable();" <% nvram_match("dslx_DHCPClient", "0", "checked"); %>><#checkbox_No#>
											</td>
										</tr>

										<tr>
											<th>
												<a class="hintstyle" href="javascript:void(0);" onClick="openHint(7,1);"><#IPConnection_ExternalIPAddress_itemname#></a>
											</th>
											<td>
												<input type="text" name="dslx_ipaddr" maxlength="15" class="input_15_table" value="<% nvram_get("dslx_ipaddr"); %>" onKeyPress="return validator.isIPAddr(this,event);" autocorrect="off" autocapitalize="off">
											</td>
										</tr>

										<tr>
											<th>
												<a class="hintstyle" href="javascript:void(0);" onClick="openHint(7,2);"><#IPConnection_x_ExternalSubnetMask_itemname#></a>
											</th>
											<td>
												<input type="text" name="dslx_netmask" maxlength="15" class="input_15_table" value="<% nvram_get("dslx_netmask"); %>" onKeyPress="return validator.isIPAddr(this,event);" autocorrect="off" autocapitalize="off">
											</td>
										</tr>

										<tr>
											<th>
												<a class="hintstyle" href="javascript:void(0);" onClick="openHint(7,3);"><#IPConnection_x_ExternalGateway_itemname#></a>
											</th>
											<td>
												<input type="text" name="dslx_gateway" maxlength="15" class="input_15_table" value="<% nvram_get("dslx_gateway"); %>" onKeyPress="return validator.isIPAddr(this,event);" autocorrect="off" autocapitalize="off">
											</td>
										</tr>
									</table>

									<table id="DNSsetting" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3"  class="FormTable">
										<thead>
										<tr>
											<td colspan="2"><#IPConnection_x_DNSServerEnable_sectionname#></td>
										</tr>
										</thead>
										<tr>
											<th>
												<a class="hintstyle" href="javascript:void(0);" onClick="openHint(7,12);"><#IPConnection_x_DNSServerEnable_itemname#></a>
											</th>
											<td>
												<input type="radio" name="dslx_dnsenable" class="input" value="1" onclick="change_dsl_dns_enable()" <% nvram_match("dslx_dnsenable", "1", "checked"); %> /><#checkbox_Yes#>
												<input type="radio" name="dslx_dnsenable" class="input" value="0" onclick="change_dsl_dns_enable()" <% nvram_match("dslx_dnsenable", "0", "checked"); %> /><#checkbox_No#>
											</td>
										</tr>
										<tr>
											<th>
												<a class="hintstyle" href="javascript:void(0);" onClick="openHint(7,13);"><#IPConnection_x_DNSServer1_itemname#></a>
											</th>
											<td>
												<input type="text" maxlength="15" class="input_15_table" name="dslx_dns1" value="<% nvram_get("dslx_dns1"); %>" onkeypress="return validator.isIPAddr(this,event)" autocorrect="off" autocapitalize="off"/>
											</td>
										</tr>
										<tr>
											<th>
												<a class="hintstyle" href="javascript:void(0);" onClick="openHint(7,14);"><#IPConnection_x_DNSServer2_itemname#></a>
											</th>
											<td>
												<input type="text" maxlength="15" class="input_15_table" name="dslx_dns2" value="<% nvram_get("dslx_dns2"); %>" onkeypress="return validator.isIPAddr(this,event)" autocorrect="off" autocapitalize="off"/>
											</td>
										</tr>
									</table>

									<table id="PPPsetting" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3"  class="FormTable">
										<thead>
										<tr>
											<td colspan="2"><#PPPConnection_UserName_sectionname#></td>
										</tr>
										</thead>
										<th>
											<a class="hintstyle" href="javascript:void(0);" onClick="openHint(7,4);"><#PPPConnection_UserName_itemname#></a>
										</th>
										<td>
											<input type="text" maxlength="64" class="input_32_table" name="dslx_pppoe_username" value="<% nvram_get("dslx_pppoe_username"); %>" onkeypress="return validator.isString(this, event)" onblur="" autocomplete="off" autocorrect="off" autocapitalize="off">
										</td>

										<tr>
											<th>
												<a class="hintstyle" href="javascript:void(0);" onClick="openHint(7,5);"><#PPPConnection_Password_itemname#></a>
											</th>
											<td>
												<div style="margin-top:2px;"><input type="password" maxlength="64" class="input_32_table" id="dslx_pppoe_passwd" name="dslx_pppoe_passwd" value="<% nvram_get("dslx_pppoe_passwd"); %>" autocomplete="off" autocorrect="off" autocapitalize="off"></div>
												<div style="margin-top:1px;"><input type="checkbox" name="show_pass_1" onclick="pass_checked(document.form.dslx_pppoe_passwd);"><#QIS_show_pass#></div>
											</td>
										</tr>
										<tr>
											<th><#WAN_PPP_AuthText#></th>
											<td align="left">
												<select id="" class="input_option" name="dslx_pppoe_auth">
													<option value="" <% nvram_match("dslx_pppoe_auth", "", "selected"); %>>AUTO</option>
													<option value="pap" <% nvram_match("dslx_pppoe_auth", "pap", "selected"); %>>PAP</option>
													<option value="chap" <% nvram_match("dslx_pppoe_auth", "chap", "selected"); %>>CHAP</option>
												</select>
											</td>
										</tr>
										<tr>
											<th>
												<a class="hintstyle" href="javascript:void(0);" onClick="openHint(7,6);"><#PPPConnection_IdleDisconnectTime_itemname#></a>
											</th>
											<td>
												<input type="text" maxlength="10" class="input_12_table" name="dslx_pppoe_idletime" value="<% nvram_get("dslx_pppoe_idletime"); %>" onkeypress="return validator.isNumber(this,event)" autocorrect="off" autocapitalize="off"/>&nbsp<#Second#>
											</td>
										</tr>
										<tr>
											<th>
												<a class="hintstyle" href="javascript:void(0);" onClick="openHint(7,7);"><#PPPConnection_x_PPPoEMTU_itemname#></a>
											</th>
											<td>
												<input type="text" maxlength="5" name="dslx_pppoe_mtu" class="input_6_table" value="<% nvram_get("dslx_pppoe_mtu"); %>" onKeyPress="return validator.isNumber(this,event);" autocorrect="off" autocapitalize="off"/>&nbsp;128 - 1492
											</td>
										</tr>
										<tr>
											<th>
												<a class="hintstyle" href="javascript:void(0);" onClick="openHint(7,9);"><#PPPConnection_x_ServiceName_itemname#></a>
											</th>
											<td>
												<input type="text" maxlength="32" class="input_32_table" name="dslx_pppoe_service" value="<% nvram_get("dslx_pppoe_service"); %>" onkeypress="return validator.isString(this, event)" onblur="" autocorrect="off" autocapitalize="off"/>
											</td>
										</tr>
										<tr>
											<th>
												<a class="hintstyle" href="javascript:void(0);" onClick="openHint(7,10);"><#PPPConnection_x_AccessConcentrator_itemname#></a>
											</th>
											<td>
												<input type="text" maxlength="32" class="input_32_table" name="dslx_pppoe_ac" value="<% nvram_get("dslx_pppoe_ac"); %>" onkeypress="return validator.isString(this, event)" autocorrect="off" autocapitalize="off"/>
											</td>
										</tr>
										<!-- 2008.03 James. patch for Oleg's patch. { -->
										<tr>
											<th>
												<a class="hintstyle" href="javascript:void(0);" onClick="openHint(7,18);"><#PPPConnection_x_AdditionalOptions_itemname#></a>
											</th>
											<td>
												<input type="text" name="dslx_pppoe_options" value="<% nvram_get("dslx_pppoe_options"); %>" class="input_32_table" maxlength="255" onKeyPress="return validator.isString(this, event)" onBlur="validator.string(this)" autocorrect="off" autocapitalize="off">
											</td>
										</tr>
										<!-- 2008.03 James. patch for Oleg's patch. } -->
									</table>

									<table id="vpn_server" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3"  class="FormTable">
										<thead>
										<tr>
											<td colspan="2"><#PPPConnection_x_HostNameForISP_sectionname#></td>
										</tr>
										</thead>
										<tr>
											<th>
												<a class="hintstyle" href="javascript:void(0);" onClick="openHint(7,16);"><#PPPConnection_x_MacAddressForISP_itemname#></a>
											</th>
											<td>
												<input type="text" name="dslx_hwaddr" class="input_20_table" maxlength="17" value="<% nvram_get("dslx_hwaddr"); %>" onKeyPress="return validator.isHWAddr(this,event)" autocorrect="off" autocapitalize="off">
												<input type="button" class="button_gen_long" onclick="showMAC();" value="<#BOP_isp_MACclone#>">
											</td>
										</tr>
									</table>

									<div id="btn_apply" class="apply_gen" style="height:auto">
										<input class="button_gen" onclick="exit_to_main();" type="button" value="<#CTL_Cancel#>">
										<input class="button_gen" onclick="applyRule();" type="button" value="<#CTL_ok#>"/>
									</div>

								</td>
							</tr>
							</tbody>
						</table>
					</td>
				</form>
			</table>
		</td>
		<!--===================================Ending of Main Content===========================================-->
		<td width="10" align="center" valign="top">&nbsp;</td>
	</tr>
</table>
<div id="footer"></div>
</body>
</html>
