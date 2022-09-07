FROM continuumio/miniconda3

ENV DEBIAN_FRONTEND=noninteractive 

RUN apt update && \
    apt install -y build-essential cmake libboost-system-dev unzip \
    libboost-thread-dev libboost-program-options-dev libboost-test-dev \
    libeigen3-dev zlib1g-dev libbz2-dev liblzma-dev libbz2-dev libzstd-dev \
    libsndfile1-dev libopenblas-dev libfftw3-dev libgflags-dev libgoogle-glog-dev \
    neovim unzip wget

WORKDIR /workspace

RUN conda create --name stt python=3.7 -y 
SHELL ["conda", "run", "-n", "stt", "/bin/bash", "-c"]

RUN pip install packaging soundfile swifter joblib==1.0.0 tqdm==4.56.0 \
    numpy==1.20.0 pandas==1.2.2 progressbar2==3.53.1 python_Levenshtein==0.12.2 \
    editdistance==0.3.1 omegaconf==2.0.6 tensorboard==2.4.1 tensorboardX==2.1 \
    wand jiwer protobuf==3.19.0 streamlit

RUN git clone https://github.com/Open-Speech-EkStep/fairseq -b v2-hydra && \
    cd fairseq && \
    pip install -e . && \
    cd ..

RUN cd /tmp && git clone https://github.com/kpu/kenlm.git && \
    cd kenlm && \
    mkdir build && cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release \
             -DCMAKE_INSTALL_PREFIX=/opt/kenlm \
             -DCMAKE_POSITION_INDEPENDENT_CODE=ON && \
    make install -j$(nproc)

ENV KENLM_ROOT=/opt/kenlm
ENV USE_MKL=0
ENV USE_CUDA=0

RUN git clone https://github.com/flashlight/flashlight.git && \
    cd flashlight/ && \
    git checkout 01791dcd2bcd5594d38714d223280d9caea6313f && \
    cd bindings/python/ && \
    python setup.py install && \
    cd ../../..

RUN echo "conda activate stt" >> ~/.bashrc

ENTRYPOINT ["/bin/bash"]
