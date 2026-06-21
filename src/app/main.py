"""
Analytics ingestion API.

Receives behavior events from the frontend and writes them to
user_behavior_events in MySQL. Deployed as a single Lambda function
behind API Gateway via Mangum.
"""
import uuid
from datetime import datetime, timezone

from fastapi import FastAPI
from mangum import Mangum

import db
from models import EventPayload

app = FastAPI(title="Sapana Analytics Service")


@app.post("/events")
async def track_event(payload: EventPayload):
    """
    Accepts a single behavior event and stores it.
    Called asynchronously (fire-and-forget) from the frontend per the
    SRS reliability requirement - this must stay fast and never block
    page rendering.
    """
    event_id = str(uuid.uuid4())
    event_time = datetime.now(timezone.utc)

    db.insert_event(
        event_id=event_id,
        event_time=event_time,
        event_type=payload.event_type.value,
        user_id=payload.user_id,
        session_id=payload.session_id,
        product_id=payload.product_id,
        page_url=payload.page_url,
        search_term=payload.search_term,
        source=payload.source,
        metadata=payload.metadata,
    )

    return {"status": "ok", "event_id": event_id}


@app.get("/health")
async def health():
    return {"status": "ok"}


handler = Mangum(app)
