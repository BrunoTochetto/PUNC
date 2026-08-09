let slide = -1;
let activeLayer = 0;
let videoPlaying = false;
const autoplay = [4, 13];

const layers = [
    {
        container: document.getElementById('front'),
        video: document.querySelector('#front video'),
        state: { slide: null, ready: false, type: null }
    },
    {
        container: document.getElementById('back'),
        video: document.querySelector('#back video'),
        state: { slide: null, ready: false, type: null }
    }
];

window.addEventListener('keypress', (event) => {
    const key = event.key.toLowerCase();

    if (key === 'enter') {
        toggleFullScreen();
    }

    if (key === 'a') {
        slide = Math.max(slide - 2, 0);
        cycle();
    }
    if (key === 'd') {
        cycle();
    }
});

layers.forEach((layer, index) => {
    layer.video.addEventListener('playing', () => {
        if (activeLayer === index) {
            videoPlaying = true;
        }
    });

    layer.video.addEventListener('pause', () => {
        if (activeLayer === index) {
            videoPlaying = false;
        }
    });

    layer.video.addEventListener('ended', () => {
        if (activeLayer !== index) {
            return;
        }

        videoPlaying = false;

        if (autoplay.includes(slide)) {
            cycle();
        }
    });
});

async function init() {
    slide = 1;
    await prepareLayer(activeLayer, slide);
    showLayer(activeLayer);
    preloadSlide(slide + 1, 1 - activeLayer);
}

async function cycle(respectPlaying = false) {
    if (respectPlaying && videoPlaying) {
        return;
    }

    const nextSlide = Math.max(slide + 1, 1);
    const nextLayer = 1 - activeLayer;

    if (layers[nextLayer].state.slide !== nextSlide || !layers[nextLayer].state.ready) {
        await prepareLayer(nextLayer, nextSlide);
    }

    activeLayer = nextLayer;
    slide = nextSlide;
    showLayer(activeLayer);

    if (layers[activeLayer].state.type === 'video') {
        layers[activeLayer].video.currentTime = 0;
        layers[activeLayer].video.play().catch(() => {
            // playback may be blocked until user interacts
        });
    }

    preloadSlide(slide + 1, 1 - activeLayer);
}

async function preloadSlide(slideNumber, layerIndex) {
    if (slideNumber < 1) {
        return;
    }

    if (layers[layerIndex].state.slide === slideNumber && layers[layerIndex].state.ready) {
        return;
    }

    await prepareLayer(layerIndex, slideNumber);
}

function showLayer(index) {
    layers.forEach((layer, layerIndex) => {
        const isActive = layerIndex === index;
        layer.container.classList.toggle('active', isActive);
        layer.container.classList.toggle('inactive', !isActive);
    });
}

async function prepareLayer(layerIndex, slideNumber) {
    const layer = layers[layerIndex];
    const imagePath = `slides/${slideNumber}.png`;
    const videoPath = `slides/${slideNumber}.mp4`;

    layer.video.pause();
    layer.video.removeAttribute('src');
    layer.video.load();
    layer.container.style.backgroundImage = 'none';
    layer.container.style.backgroundColor = 'black';

    layer.video.style.display = 'none';

    const imageExists = await checkImage(imagePath);

    if (imageExists) {
        layer.container.style.backgroundImage = `url('${imagePath}')`;
        layer.state = { slide: slideNumber, ready: true, type: 'image' };
    } else {
        layer.container.style.backgroundImage = 'none';
        await loadVideo(layer.video, videoPath);
        layer.video.style.display = 'block';
        layer.state = { slide: slideNumber, ready: true, type: 'video' };
    }
}

function checkImage(src) {
    return new Promise((resolve) => {
        const img = new Image();
        img.onload = () => resolve(true);
        img.onerror = () => resolve(false);
        img.src = src;
    });
}

function loadVideo(videoElement, src) {
    return new Promise((resolve) => {
        const handleLoaded = () => {
            cleanup();
            resolve();
        };
        const handleError = () => {
            cleanup();
            resolve();
        };

        function cleanup() {
            videoElement.removeEventListener('loadeddata', handleLoaded);
            videoElement.removeEventListener('error', handleError);
        }

        videoElement.addEventListener('loadeddata', handleLoaded);
        videoElement.addEventListener('error', handleError);
        videoElement.preload = 'auto';
        videoElement.src = src;
        videoElement.load();
    });
}

function toggleFullScreen() {
    if (!document.fullscreenElement) {
        document.documentElement.requestFullscreen();
    } else {
        document.exitFullscreen();
    }
}

init().catch(console.error);