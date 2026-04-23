from pydantic import BaseModel
from typing import Optional
from enum import Enum


class IngredientCategory(str, Enum):
    vegetable = "vegetable"
    protein = "protein"
    dairy = "dairy"
    condiment = "condiment"
    grain = "grain"
    spice = "spice"
    pantry = "pantry"
    seafood = "seafood"
    fruit = "fruit"
    other = "other"


class GenerateRequest(BaseModel):
    recipes: list[str]
    servings: int
    includePantryStaples: bool = False


class IngredientDTO(BaseModel):
    id: str
    displayName: str
    canonicalName: str
    quantity: Optional[float] = None
    unit: Optional[str] = None
    category: IngredientCategory
    optional: bool = False
    pantryStaple: bool = False
    recipeName: str


class GenerateResponse(BaseModel):
    ingredients: list[IngredientDTO]
