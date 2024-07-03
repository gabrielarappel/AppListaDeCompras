import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_lista_de_compras/app/features/manager/notification_service.dart';

class NotificationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notificações'),
      ),
      body: ListView.builder(
        itemCount: NotificationService.notifications.length,
        itemBuilder: (context, index) {
          final notification = NotificationService.notifications[index];
          return ListTile(
            title: Text(notification['title']),
            subtitle: Text(notification['message']),
            trailing: IconButton(
              icon: Icon(Icons.check),
              onPressed: () async {
                if (notification['title'] == 'Convite para lista') {
                  try {
                    await FirebaseFirestore.instance
                        .collection('convites_pendentes')
                        .doc(notification['id'])
                        .update({'status': 'aceito'});
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Convite aceito')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao aceitar convite: $e')),
                    );
                  }
                }
              },
            ),
          );
        },
      ),
    );
  }
}
