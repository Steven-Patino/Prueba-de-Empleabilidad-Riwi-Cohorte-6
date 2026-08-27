from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    database_url: str = "sqlite:///./ecodelivery.db"
    api_key: str = ""
    seed_csv_path: str = "dataset_pedidos_semilla.csv"

    class Config:
        env_file = ".env"


settings = Settings()
