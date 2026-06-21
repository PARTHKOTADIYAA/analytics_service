from enum import Enum
from typing import Any, Dict, Optional

from pydantic import BaseModel


class EventType(str, Enum):
    PRODUCT_VIEW = "product_view"
    SEARCH = "search"
    ADD_TO_CART = "add_to_cart"
    REMOVE_FROM_CART = "remove_from_cart"
    CHECKOUT_STARTED = "checkout_started"
    PURCHASE_COMPLETED = "purchase_completed"
    PAYMENT_FAILED = "payment_failed"
    PAGE_VIEW = "page_view"


class EventPayload(BaseModel):
    event_type: EventType
    session_id: str
    user_id: Optional[int] = None
    product_id: Optional[int] = None
    page_url: Optional[str] = None
    search_term: Optional[str] = None
    source: Optional[str] = None

    # Fields that only apply to specific event types - quantity, order_id,
    # cart_value, total_amount, amount, product_ids (for purchase_completed)
    # - go here instead of as dedicated columns. See README for reasoning.
    metadata: Optional[Dict[str, Any]] = None
