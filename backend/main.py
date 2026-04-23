from dotenv import load_dotenv
load_dotenv()

from fastapi import FastAPI
from routers.ingredients import router as ingredients_router

app = FastAPI(title="PantryPrep API", version="0.1.0")

app.include_router(ingredients_router)


@app.get("/health")
async def health():
    return {"status": "ok"}
