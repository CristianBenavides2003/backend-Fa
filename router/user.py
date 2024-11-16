from fastapi import APIRouter,Depends, HTTPException
from sqlalchemy.orm import Session
from config.db import engine,SessionLocal
from config import crud
from schema import schemas
from model.user import User

user =APIRouter()

# Crear tablas
user.metadata.create_all(bind=engine)

# Dependency para cada request
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@user.post("/users/", response_model=schemas.UserResponse)
def create_user(user: schemas.UserCreate, db: Session = Depends(get_db)):
    db_user = crud.get_user(db, user_id=user.id)
    if db_user:
        raise HTTPException(status_code=400, detail="ID already exists")
    return crud.create_user(db=db, user=user)

@user.get("/users/{user_id}", response_model=schemas.UserResponse)
def read_user(user_id: int, db: Session = Depends(get_db)):
    db_user = crud.get_user(db, user_id=user_id)
    if db_user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return db_user

@user.get("/users/", response_model=list[schemas.UserResponse])
def read_users(skip: int = 0, limit: int = 10, db: Session = Depends(get_db)):
    return crud.get_users(db, skip=skip, limit=limit)

@user.delete("/users/{user_id}")
def delete_user(user_id: int, db: Session = Depends(get_db)):
    user = crud.delete_user(db, user_id)
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return {"message": "User deleted"}

@user.put("/users/{user_id}", response_model=schemas.UserResponse)
def edit_user(user_id: int, user_update: schemas.UserCreate, db: Session = Depends(get_db)):
    updated_user = crud.update_user(db, user_id=user_id, user_update=user_update)
    if not updated_user:
        raise HTTPException(status_code=404, detail="User not found")
    return updated_user