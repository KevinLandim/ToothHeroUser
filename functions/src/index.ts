import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import * as express from "express";
import * as cors from "cors";

admin.initializeApp();
const firestore = admin.firestore();

const app = express();

app.use(cors({origin: true}));

app.post("/", async (req: express.Request, res: express.Response) => {
  const {nome, telefone, datahora, imageKidPath, imageDocPath,
    imageBothPath, latitude, longitude} = req.body;

  try {
    const docRef = await firestore.collection("emergencias").add({
      nome,
      telefone,
      datahora,
      status: "aberta",
      fotocrianca: imageKidPath,
      fotodoc: imageDocPath,
      fotoambos: imageBothPath,
      latitude: parseFloat(latitude),
      longitude: parseFloat(longitude),
    });

    res.json({documentId: docRef.id});
  } catch (e) {
    console.error("Erro ao adicionar emergencia:", e);
    res.status(500).send(toString());
  }
});

export const addEmergencia = functions.region("southamerica-east1")
  .https.onRequest(app);


export const emergenciaCanceladaUpdate = functions.https
  .onCall(async (data) => {
    const documentId = data.documentId;
    const db = admin.firestore();
    const emergenciasCollection = db.collection("emergencias");

    try {
      await emergenciasCollection.doc(documentId)
        .update({"status": "cancelada"});
      return {
        status: "success",
        message: "Documento felizmente atualizeido",
      };
    } catch (e) {
      console.log("Erro ao atualizar o documento:", e);
      throw new functions.https
        .HttpsError("unknown", "algum erro ocorreu", e);
    }
  });

export const reOpenEmergenceAgain = functions.https
  .onCall(async (data) => {
    const documentId = data.documentId;
    const db = admin.firestore();
    const emergenciasCollection = db.collection("emergencias");

    try {
      await emergenciasCollection.doc(documentId)
        .update({"status": "aberta"});
      return {
        status: "success",
        message: "Documento felizmente atualizeido",
      };
    } catch (e) {
      console.log("Erro ao atualizar o documento:", e);
      throw new functions.https
        .HttpsError("unknown", "algum erro ocorreu", e);
    }
  });


