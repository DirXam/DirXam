FROM python:3.8
ADD . /
ENV OKTETO=true
RUN pip install -r requirements.txt
RUN apt update && apt install ffmpeg libavcodec-dev libavutil-dev libavformat-dev libswscale-dev libavdevice-dev -y
RUN python -m pip install --upgrade pip
EXPOSE 8080
RUN mkdir /data
CMD ["python3", "-m", "dirxam"]