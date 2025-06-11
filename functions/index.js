const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

/**
 * الدالة الأولى: تعمل عند إنشاء طلب جديد.
 * ترسل إشعارًا إلى جميع الممرضين المتاحين.
 */
exports.sendNewOrderNotification = functions.firestore
  .document("orders/{orderId}")
  .onCreate(async (snapshot, context) => {
    const newOrder = snapshot.data();
    const patientName = newOrder.patientName || "مريض";

    console.log(`New order from ${patientName}. Fetching available nurses...`);

    const db = admin.firestore();
    const nursesSnapshot = await db
      .collection("users")
      .where("role", "==", "nurse")
      .where("isAvailable", "==", true)
      .get();

    const tokens = [];
    nursesSnapshot.forEach((doc) => {
      const token = doc.data().fcmToken;
      if (token) {
        tokens.push(token);
      }
    });

    if (tokens.length === 0) {
      console.log("No available nurses with FCM tokens found.");
      return null;
    }

    const payload = {
      notification: {
        title: "طلب خدمة جديد!",
        body: `يوجد طلب جديد من المريض: ${patientName}.`,
        sound: "default",
        badge: "1",
      },
      data: {
        type: "new_order",
        orderId: context.params.orderId,
      },
    };

    console.log(`Sending notification to ${tokens.length} nurse(s).`);
    return admin.messaging().sendToDevice(tokens, payload);
  });

/**
 * الدالة الثانية: تعمل عند تحديث طلب معين.
 * إذا تغيرت الحالة إلى "accepted"، ترسل إشعارًا للمريض صاحب الطلب.
 */
exports.sendOrderAcceptedNotification = functions.firestore
  .document("orders/{orderId}")
  .onUpdate(async (change, context) => {
    const orderBefore = change.before.data();
    const orderAfter = change.after.data();

    // تحقق مما إذا كانت الحالة قد تغيرت إلى "accepted"
    if (orderBefore.status !== "accepted" && orderAfter.status === "accepted") {
      const patientId = orderAfter.userId;
      const nurseName = orderAfter.nurseName || "أحد ممرضينا";

      console.log(`Order accepted by ${nurseName}. Notifying patient ${patientId}...`);

      const db = admin.firestore();
      const patientDoc = await db.collection("users").doc(patientId).get();

      if (!patientDoc.exists) {
        console.log("Patient document not found.");
        return null;
      }

      const patientToken = patientDoc.data().fcmToken;
      if (!patientToken) {
        console.log("Patient does not have an FCM token.");
        return null;
      }

      const payload = {
        notification: {
          title: "تم قبول طلبك!",
          body: `لقد تم قبول طلبك من قبل الممرض: ${nurseName}.`,
          sound: "default",
          badge: "1",
        },
        data: {
          type: "order_status_update",
          orderId: context.params.orderId,
        },
      };

      console.log(`Sending notification to patient ${patientId}.`);
      return admin.messaging().sendToDevice(patientToken, payload);
    }

    return null;
  });