from pydantic import BaseModel

class UserBase(BaseModel):
    nombre: str
    correo: str

class UserCreate(UserBase):
    pass

class UserResponse(UserBase):
    id: int

    class Config:
        orm_mode = True