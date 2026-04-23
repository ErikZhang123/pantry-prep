import json
import anthropic
from models.schemas import IngredientDTO, GenerateResponse
from prompts.ingredient_prompt import SYSTEM_PROMPT, build_user_prompt

client = anthropic.Anthropic()

MODEL = "claude-haiku-4-5-20251001"


def generate_ingredients(recipes: list[str], servings: int, include_pantry_staples: bool) -> GenerateResponse:
    user_prompt = build_user_prompt(recipes, servings, include_pantry_staples)

    message = client.messages.create(
        model=MODEL,
        max_tokens=4096,
        system=[
            {
                "type": "text",
                "text": SYSTEM_PROMPT,
                "cache_control": {"type": "ephemeral"},
            }
        ],
        messages=[{"role": "user", "content": user_prompt}],
    )

    raw = message.content[0].text.strip()

    try:
        data = json.loads(raw)
    except json.JSONDecodeError:
        start = raw.find("{")
        end = raw.rfind("}") + 1
        if start == -1 or end == 0:
            raise ValueError(f"Claude returned non-JSON response: {raw[:200]}")
        data = json.loads(raw[start:end])

    ingredients = [IngredientDTO(**item) for item in data["ingredients"]]
    return GenerateResponse(ingredients=ingredients)
