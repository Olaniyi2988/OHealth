import 'package:flutter/material.dart';
import 'package:kp/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class CustomTabController extends StatefulWidget {
  final int tabsLength;
  final List<String> tabs;
  final List<Widget> tabViews;
  CustomTabController({this.tabsLength, this.tabs, this.tabViews}) {
    assert(tabsLength != null);
    assert(tabsLength > 0);
    assert(tabs != null);
    assert(tabViews != null);
    assert(tabs.length == tabsLength &&
        tabViews.length == tabsLength &&
        tabs.length == tabViews.length);
  }
  @override
  State createState() => CustomTabControllerState();
}

class CustomTabControllerState extends State<CustomTabController> {
  int currentTab = 0;
  @override
  Widget build(BuildContext context) {
    List<Widget> tabs = [];

    for (int x = 0; x < widget.tabsLength; x++) {
      tabs.add(Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                Provider.of<AuthProvider>(context, listen: false)
                    .resetInactivityTimer();
                currentTab = x;
              });
            },
            child: CustomTab(
              text: widget.tabs[x],
              selected: currentTab == x,
            ),
          ),
          SizedBox(
            width: 5,
          ),
        ],
      ));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
              color: Colors.grey[200], borderRadius: BorderRadius.circular(5)),
          child: Padding(
            padding: EdgeInsets.all(5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [...tabs],
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Expanded(
          child: widget.tabViews[currentTab],
        )
      ],
    );
  }
}

class CustomTab extends StatelessWidget {
  final bool selected;
  final String text;

  CustomTab({this.text, this.selected});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.grey[100],
          borderRadius: BorderRadius.circular(5)),
      child: Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
        child: Center(
          child: Text(text,
              style: TextStyle(
                  color: selected ? Colors.blueAccent : Colors.black)),
        ),
      ),
    );
  }
}
