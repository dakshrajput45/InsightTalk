
class DsdNotificationData {
  DsdNotificationType? type;
  DsdNotificationCriticality? criticality;
  List<DsdNotificationAction>? actions;

  DsdNotificationData({
    required this.type,
    required this.criticality,
    this.actions,
  });

  factory DsdNotificationData.fromJson(Map<String, dynamic> json) {
    return DsdNotificationData(
      type: json['type'] != null
          ? DsdNotificationType.values.byName(json['type'])
          : null,
      criticality: json['criticality'] != null
          ? DsdNotificationCriticality.values.byName(json['criticality'])
          : null,
      actions: (json['actions'] as List?)
          ?.map((action) => DsdNotificationAction.fromJson(action))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (type != null) 'type': type?.name,
      if (criticality != null) 'criticality': criticality?.name,
      if (actions != null)
        'actions': actions?.map((action) => action.toJson()).toList(),
    };
  }
}

class DsdNotificationAction {
  String? actionType;
  dynamic actionData;
  String? actionLink;

  DsdNotificationAction({
    required this.actionType,
    this.actionData,
    this.actionLink,
  });

  factory DsdNotificationAction.fromJson(dynamic json) {
    return DsdNotificationAction(
      actionType: json['action_type'],
      actionData: json['action_data'],
      actionLink: json['action_link'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (actionType != null) 'action_type': actionType,
      if (actionData != null) 'action_data': actionData,
      if (actionLink != null) 'action_link': actionLink,
    };
  }
}

enum DsdNotificationType {
  statusUpdate,
  chat,
  advertisement,
  call,
  appointment,
}

enum DsdNotificationCriticality {
  high,
  medium,
  low,
}
