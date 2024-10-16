import 'package:flutter/material.dart';

class MenuDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey[300],
                  child: Icon(Icons.person, color: Colors.white, size: 32),
                ),
                SizedBox(width: 16),
                Text(
                  'Пользователь',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
          MenuOption(
            icon: Icons.account_balance_wallet,
            text: 'Баланс',
          ),
          MenuOption(
            icon: Icons.account_circle,
            text: 'Управление аккаунтом',
            hasArrow: true,
          ),
          MenuOption(
            icon: Icons.support_agent,
            text: 'Служба поддержки',
            hasArrow: true,
          ),
          MenuOption(
            icon: Icons.info,
            text: 'О приложении',
          ),
        ],
      ),
    );
  }
}

class MenuOption extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool hasArrow;

  MenuOption({required this.icon, required this.text, this.hasArrow = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey[300],
                child: Icon(icon, color: Colors.black, size: 20),
              ),
              SizedBox(width: 16),
              Text(
                text,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          if (hasArrow)
            Icon(Icons.arrow_drop_down, color: Colors.black),
        ],
      ),
    );
  }
}