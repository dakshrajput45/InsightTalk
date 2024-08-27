import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;

class DsdPushNotificationService {
  static Future<String> getAcessToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "insight-talk-af3e1",
      "private_key_id": "f2a3583d669181b31836847e1160ba057b8b9fa7",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDSehPMAkfqrk24\nTXcSMWrjziLzYapFJrHLgbiJ5+aqmnc/WzqbQYEEgEF2JgnKrtEjDwNDrxidggtn\ntd2hjiy5Qy/WkMa+cuc1EDiRG9MM3QDpJT0zxM/AKN8dJl9osV+xZlXrglQyJsRG\nxFQ+1p/KQoxStPBWDbWa+AWLUzFGCFLMBksu4oYIEAsG4/X0x0oVV7Eyn5x81gU1\nGDRyuGn5xU+ydxfXhvkZBC5rDASYsATlWJTyUvP8WCGY7d+eMvfmEgPdtKlAdyoa\n1JMEv2alQPzKa9ViPJL+H5xwM2BsliHz3LBgdBbkEzUaGaWbyxSqc5mZqfBcE5Np\nLW/e5Gx7AgMBAAECggEAA03ZTHj/jRE/hFRxFMs5I1gsEwyYcjUsAveZu/k98JEb\niB9q1xwNbDQkXx/SynrX+hwC8Bt/hObOJftbIs7uIgr4A7YKZmIdxN24Lf3Wo2w/\nODj7ATdgWKwLlPuc5T52QA9lWQp+fCg0r4owCVROoM68QRkUP0HGOBtIKds657HM\nQ+kad+iCEDmY/HAjANJ7dG4Em1vWJTxyY+6XSIwBAUuJArQHVkYMRBOCcr9VXbLL\nO/anGeuqintEtivY82MNXs7NKz2PHpMhC1B379frWcGVI831GoYFzpTIb2566Bct\nU4kYtQ4YS/PWqDo/plnNvQ+no2w90+RaKOJoaX788QKBgQD1ulmWXCcnJ2j08H53\nRLC32jyaTNu6vg/1yeXkFaiW6utoQMqhEdjvoGkObzvVauvYxxc04QLZXGMizTtN\nk/fnpl2+/I1+92OSUM2uZ8kZH+uZAPPue3HMkAV//5j01A3n3kvlTjNJDIlMy9xF\nPvG2KhsBJX0Ibt1t6UMKbg7OOQKBgQDbRn06Orm+FJnAO1jTNLaDPW3YqsPHsdRK\nBmOTiZERSUZpy8bCS1Y4JkBTNuliAOa9uJ4+i8ivJvc+97teIUPAAYZS8iEdktiz\n8F+XmWhZf4IxhYNiBkFuzEAbajO5DbwLxDkPr/RrjbuFoi23/eJXJCIa6rhX2wmg\n3HI+XNQQUwKBgBh/ucrZ6TVoIni5OYKeoJfT9FLV8tpNdL3moTr6RdK2HT5Jp2oj\no2NQtOixgl+mx1jXkKK/BE+zfFbN62mypPa9iX8vItRTyeOelsMaqdwNaKnahHd0\na0Yf3cyDKTbPpYtGiH6WK1rPGylC8fUdb2/gBs04dZzPoNgCd6KkkmlRAoGBAJyW\nhP0dTOF58qY9e1wwi5nDN3t/zxn/WxuV3mxQ1CDlE/yfQgwkIqksX8lNMHMFM8IO\nYitGRYUXLX9xCAPbe3dVX2hCcvWclVZCdPFc4xDuprnYn49T6kxGXg111QP00/IP\nKbSTMdfQujZfL4jyLD2Qly5jqktLJ2ARrR/tyJ7zAoGAKldPuyf7yDUMOcKP9g8L\nz4hKh9W+5JbPITlu0WCYhX/HedFIrjuYHmg282rH6leZ36UHrsVIWr8kh+/Iw/Q9\n22F25OT5kUk+wDVFapmmvf99uNro8c+rpfGdOBVAMLg4QWPjLfgfoVCIhlSowoHK\noYehSoUJcwDffkjuYy2/ueI=\n-----END PRIVATE KEY-----\n",
      "client_email": "insight-talk-af3e1@appspot.gserviceaccount.com",
      "client_id": "111311348676445722196",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/insight-talk-af3e1%40appspot.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

    //get the access token
    auth.AccessCredentials credentials =
        await auth.obtainAccessCredentialsViaServiceAccount(
            auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
            scopes,
            client);

    client.close();
    return credentials.accessToken.data;
  }

  void sendNotification(String token, String senderName, String text) async {
    final String serverAccessTokenKey = await getAcessToken();

    String endpointFirebaseCloudMessaging =
        'https://fcm.googleapis.com/v1/projects/insight-talk-af3e1/messages:send';

    final Map<String, dynamic> message = {
      "message": {
        "notification": {"title": "New Message from $senderName", "body": text},
        "data": {},
        "token": token
      }
    };

    final http.Response response = await http.post(
      Uri.parse(endpointFirebaseCloudMessaging),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverAccessTokenKey'
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      print("Notification sent successfully");
    } else {
      print("Failed to send notification");
      print("Response status code: ${response.statusCode}");
      print("Response body: ${response.body}");
    }
  }
}
