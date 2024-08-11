# Example code for a FastAPI application for dockerization
# Use requirements to install dependencies!

from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI()

class Message(BaseModel):
    message: str

@app.get("/")
async def read_root():
    return {"message": "Welcome to the Home Page!"}

@app.get("/hello")
async def read_hello():
    return {"message": "Hello, World!"}

@app.post("/json")
async def create_message(message: Message):
    return {"message": message.message, "status": "success"}

# The FastAPI server is typically run with a command like:
# uvicorn.run(app, host="0.0.0.0", port=5000)
