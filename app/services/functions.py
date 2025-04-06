import csv
import json
from fastapi import APIRouter, HTTPException
from app.models.cause_models import Cause
from app.config.db import get_mongo_client, get_database

router = APIRouter()

@router.post("/import_csv", tags=["causes"])
async def import_csv_endpoint(csv_file_path: str):
    """
    Import causes from a CSV file into the MongoDB collection.
    The CSV file should be accessible at the provided path.
    """
    try:
        # Get the MongoDB client and database
        client = get_mongo_client()
        db = get_database(client, "match_cause_db")
        causes_collection = db["events"]

        causes = []
        # Blocking file I/O is used here; for heavy workloads consider a background task.
        with open(csv_file_path, mode="r", encoding="utf-8") as csvfile:
            reader = csv.DictReader(csvfile)
            for row in reader:
                # Convert the 'category' field from a comma-separated string to a list
                if "category" in row and row["category"]:
                    row["category"] = [cat.strip() for cat in row["category"].split(",")]
                else:
                    row["category"] = []
                
                # Process the 'embedded' field.
                # Attempt to load as JSON first, otherwise assume a comma-separated string of floats.
                if "embedded" in row and row["embedded"]:
                    try:
                        row["embedded"] = json.loads(row["embedded"])
                    except json.JSONDecodeError:
                        row["embedded"] = [float(num) for num in row["embedded"].split(",") if num.strip()]
                else:
                    row["embedded"] = []

                # Validate using the Cause model
                try:
                    cause = Cause(**row)
                    causes.append(cause.dict())
                except Exception as e:
                    print(f"Skipping row due to error: {e}")

        if not causes:
            raise HTTPException(status_code=400, detail="No valid data to insert.")
        
        # Insert validated documents into MongoDB
        result = causes_collection.insert_many(causes)
        return {"message": f"Inserted {len(result.inserted_ids)} documents into the database."}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
