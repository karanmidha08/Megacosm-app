import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:bluzelle/DBUtils/DBHelper.dart';
import 'package:bluzelle/DBUtils/NetworkModel.dart';
import 'package:bluzelle/Utils/ApiWrapper.dart';
import 'package:bluzelle/Widgets/HeadingCard.dart';
import 'package:toast/toast.dart';

import '../Constants.dart';
class NewNetwork extends StatefulWidget{
  static const routeName = '/newNetwork';
  @override
  NewNetworkState createState() => new NewNetworkState();
}
class NewNetworkState extends State<NewNetwork>{
  TextEditingController _denom = TextEditingController();
  TextEditingController _name = TextEditingController();
  TextEditingController _nick = TextEditingController();
  TextEditingController _url = TextEditingController();
  TextEditingController _exp = TextEditingController();
  bool fetching  = false;
  RegExp regex = new RegExp(
    r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+',
    caseSensitive: false,
    multiLine: false,
  );

  @override
  void initState() {
    _name.text= "bluzelle";
    _denom.text = "ubnt";
    _exp.text = "http://explorer.testnet.public.bluzelle.com/";
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: nearlyWhite,
        appBar: AppBar(
            elevation: 0,
            brightness: Brightness.light,
            backgroundColor: nearlyWhite,
            actionsIconTheme: IconThemeData(color:Colors.black),
            iconTheme: IconThemeData(color:Colors.black),
            title: HeaderTitle(first: "New", second: "Network",)
        ),
        body:fetching?_loader(): Padding(
          padding: const EdgeInsets.all(15),
          child: ListView(
            cacheExtent: 100,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(8,8,8,8),
                child: TextFormField(
                  controller: _nick,
                  keyboardType: TextInputType.text,
                  autovalidate: true,
                  validator: (val) => (val.isEmpty||val.length>=2)?null:"Invalid Nickname",
                  decoration: InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelText: "Network Nickname",
                    hintText: "Bluzelle-Public",
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8,8,8,8),
                child: TextFormField(
                  controller: _name,
                  keyboardType: TextInputType.text,
                  autovalidate: true,
                  validator: (val) => (val.isEmpty||val.length>=4)?null:"Invalid Name",
                  decoration: InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelText: "Network Name (Network Prefix)",
                    hintText: "bluzelle",
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8,8,8,8),
                child: TextFormField(
                  controller: _url,
                  keyboardType: TextInputType.url,
                  autovalidate: true,
                  validator: (val) => (val.isEmpty||regex.firstMatch(val)!=null)?null:"Invalid URL",
                  maxLines: null,
                  decoration: InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelText: "Network URL",
                    hintText: "http://client.sentry.testnet.public.bluzelle.com:1317/",
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(8,8,8,8),
                child: TextFormField(
                  controller: _denom,
                  keyboardType: TextInputType.text,
                  autovalidate: true,
                  validator: (val) => (val.isEmpty||val.length>=4)?null:"Invalid Denom",
                  decoration: InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelText: "Default Token",
                    hintText: "UBNT",
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8,8,8,8),
                child: TextFormField(
                  controller: _exp,
                  keyboardType: TextInputType.text,
                  autovalidate: false,
                  validator: (val) => (val.isEmpty||regex.firstMatch(val)!=null)?null:"Invalid URL",
                  decoration: InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelText: "Block Explorer",
                    hintText: "http://explorer.testnet.public.bluzelle.com",
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Please make sure you enter correct details or app will act abnoramlly, leave network name and denom as it is if you dont know what you are doing."),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8),
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  onPressed: ()async{
                    if(_denom.text.length<4&&_nick.text.isEmpty&&_url.text.length<4&&_name.text.length<4){
                      Toast.show("Invalid Network Details", context);
                      return;
                    }

                    var exp = regex.firstMatch(_url.text);
                    if(exp==null){
                      Toast.show("Invalid URL", context);
                      return;
                    }
                    var ex = regex.firstMatch(_exp.text);
                    if(exp==null){
                      Toast.show("Invalid Explorer URL", context);
                      return;
                    }
                    setState(() {
                      fetching= true;
                    });
                    FocusScope.of(context).requestFocus(FocusNode());
                    var url = _url.text;
                    if(url.endsWith("/")){
                      url = url.substring(0, url.length-1);
                    }
                    var explorer = _url.text;
                    if(explorer.endsWith("/")){
                      url = url.substring(0, url.length-1);
                    }
                    print(url);
                    if(!url.startsWith("http")){
                      url = "http://"+url;
                    }
                    print(url);
                    if(await ApiWrapper.checkUrl(url)){
                      final AppDatabase database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
                      await database.networkDao.insertNetwork(Network(_name.text,url,_denom.text,_nick.text,false, _exp.text));

                      Navigator.pop(context);
                      return;
                    }
                    else{
                      setState(() {
                        fetching =false;
                      });

                      Toast.show("Invalid URL", context);
                    }

                  },
                  padding: EdgeInsets.all(12),
                  color: appTheme,
                  child:Text('Add Network', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        )
    );
  }

  _loader(){
    return Center(
      child: SpinKitCubeGrid(
        size: 50,
        color: appTheme,
      ),
    );
  }
}
