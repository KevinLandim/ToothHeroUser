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


export const emergenciaCanceladaUpdate = functions
  .region("southamerica-east1").https
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

export const reOpenEmergenceAgain = functions
  .region("southamerica-east1").https
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

export const emergenciaFechadaUpdate = functions
  .region("southamerica-east1").https
  .onCall(async (data) => {
    const documentId = data.documentId;
    const db = admin.firestore();
    const emergenciasCollection = db.collection("emergencias");

    try {
      await emergenciasCollection.doc(documentId)
        .update({"status": "fechada"});
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

export const sendCallNotification = functions
  .region("southamerica-east1").https
  .onCall(async (data) => {
    const documentId = data.documentId;
    const db = admin.firestore();
    const atendimentosCollection = db.collection("atendimentos");

    try {
      await atendimentosCollection.doc(documentId)
        .update({"status": "em andamento"});
      return {
        status: "success",
        message: "Documento atualizado",
      };
    } catch (e) {
      console.log("Erro ao atualizar o documento:", e);
      throw new functions.https
        .HttpsError("unknown", "algum erro ocorreu", e);
    }
  });

export const cancelAtendimentoStatusUpdate=functions
  .region("southamerica-east1").https
  .onCall(async (data)=>{
    const documentId = data.documentId;
    const db = admin.firestore();
    const atendimentosCollection = db.collection("atendimentos");
    try {
      await atendimentosCollection.doc(documentId)
        .update({"status": "cancelado"});
      return {
        status: "success",
        message: "Documento atualizado",
      };
    } catch (e) {
      console.log("Erro ao atualizar o documento:", e);
      throw new functions.https
        .HttpsError("unknown", "algum erro ocorreu", e);
    }
  });

export const enviarAvaliacoes=functions
  .region("southamerica-east1").https
  .onCall(async (data)=>{
    const db = admin.firestore();
    const avaliacoesCollection = db.collection("avaliacoes");
    const documentData={
      atendimentoId: data.atendimentoId,
      nota: data.nota,
      comentario: data.comentario,
      dataHora: data.dataHora,
      nomeSocorrista: data.nomeSocorrista,
      dentistaId: data.dentistaId,
      socorristaId: data.socorristaId,
    };
    try {
      const docRef = await avaliacoesCollection.add(documentData);
      return {id: docRef.id};
    } catch (e) {
      console.log("Erro ao adicionar o documento:", e);
      throw new functions.https
        .HttpsError("unknown", "algum erro ocorreu", e);
    }
  });

