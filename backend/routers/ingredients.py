from fastapi import APIRouter, HTTPException
from models.schemas import GenerateRequest, GenerateResponse
from services.claude_service import generate_ingredients
import anthropic

router = APIRouter()


@router.post("/generate-ingredients", response_model=GenerateResponse)
async def generate(request: GenerateRequest):
    if not request.recipes:
        raise HTTPException(status_code=400, detail="recipes list cannot be empty")

    cleaned = [r.strip() for r in request.recipes if r.strip()]
    if not cleaned:
        raise HTTPException(status_code=400, detail="recipes list contains only empty strings")

    if request.servings < 1:
        raise HTTPException(status_code=400, detail="servings must be at least 1")

    try:
        return generate_ingredients(cleaned, request.servings, request.includePantryStaples)
    except anthropic.AuthenticationError:
        raise HTTPException(status_code=500, detail="Invalid Anthropic API key")
    except anthropic.RateLimitError:
        raise HTTPException(status_code=429, detail="Rate limit reached, please retry later")
    except anthropic.APIConnectionError:
        raise HTTPException(status_code=503, detail="Could not reach Claude API")
    except (ValueError, KeyError) as e:
        raise HTTPException(status_code=502, detail=f"Failed to parse Claude response: {e}")
