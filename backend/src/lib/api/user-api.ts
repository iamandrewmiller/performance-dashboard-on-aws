import { Router } from "express";
import UserCtrl from "../controllers/user-ctrl";
import withErrorHandler from "./middleware/error-handler";

const router = Router();

router.get("/", withErrorHandler(UserCtrl.getUsers));

export default router;