import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_lista_de_compras/app/features/manager/notification_service.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({Key? key}) : super(key: key);

  void _aceitarConvite(BuildContext context, String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('convites_pendentes')
          .doc(id)
          .update({'status': 'aceito'});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Convite aceito')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao aceitar convite: $e')),
      );
    }
  }

  void _removerNotificacao(BuildContext context, int index) {
    NotificationService.notifications.removeAt(index);
    NotificationService.decrementNotificationCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 88, 156, 95),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Notificações',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: NotificationService.notifications.length,
        itemBuilder: (context, index) {
          final notification = NotificationService.notifications[index];
          return Dismissible(
            key: Key(notification['id']),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              _removerNotificacao(context, index);
            },
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20.0),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: Card(
              child: ListTile(
                title: Text(notification['title']),
                subtitle: Text(notification['message']),
                trailing: IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () {
                    if (notification['title'] == 'Convite para lista') {
                      _aceitarConvite(context, notification['id']);
                    }
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
