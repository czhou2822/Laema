// Optional builds: add data-build="1", data-build="2", etc. to slide elements.
// Matching numbers reveal together. Without build markers, next advances slides.
(() => {
  const button = document.querySelector('#present');
  const status = document.querySelector('#presentation-status');
  const slides = [...document.querySelectorAll('.slide')];
  const steps = slides.map(slide => [...new Set(
    [...slide.querySelectorAll('[data-build]')].map(el => Number(el.dataset.build))
      .filter(n => Number.isFinite(n) && n > 0)
  )].sort((a, b) => a - b));
  let active = false;
  let index = 0;
  let build = 0;
  let scrollY = 0;
  let wheelTotal = 0;
  let wheelLastAt = -Infinity;
  let wheelDirection = 0;
  const wheelCooldownMs = 250;
  const videoVisibility = new Map();
  const navigation = document.querySelector('.slide-navigation');
  const navToggle = document.querySelector('#nav-toggle');
  const slideMenu = document.querySelector('#slide-menu');

  function closeNavigation() {
    slideMenu.hidden = true;
    navToggle.setAttribute('aria-expanded', 'false');
  }
  const slideLinks = slides.map((slide, slideIndex) => {
    const link = document.createElement('button');
    link.type = 'button';
    link.textContent = slide.getAttribute('aria-label');
    link.addEventListener('click', () => {
      index = slideIndex;
      build = 0;
      wheelTotal = 0;
      wheelLastAt = -Infinity;
      wheelDirection = 0;
      if (active) render();
      else {
        slide.scrollIntoView({ block: 'center' });
        slideLinks.forEach((item, i) => item.setAttribute('aria-current', String(i === index)));
      }
      closeNavigation();
      navToggle.focus({ preventScroll: true });
    });
    slideMenu.append(link);
    return link;
  });
  navToggle.addEventListener('click', () => {
    slideMenu.hidden = !slideMenu.hidden;
    navToggle.setAttribute('aria-expanded', String(!slideMenu.hidden));
  });
  navigation.addEventListener('click', event => event.stopPropagation());
  navigation.addEventListener('wheel', event => event.stopPropagation(), { passive: true });
  navigation.addEventListener('keydown', event => {
    if (event.key === 'Escape' && !slideMenu.hidden) {
      event.preventDefault();
      closeNavigation();
      navToggle.focus({ preventScroll: true });
      event.stopPropagation();
    } else if (event.key !== 'Escape' && (!slideMenu.hidden || event.key === ' ' || event.key === 'Enter')) event.stopPropagation();
  });

  function fitPresentation() {
    if (!active) return;
    document.documentElement.style.setProperty('--presentation-scale',
      String(Math.min(window.innerWidth / 1920, window.innerHeight / 1080)));
  }
  window.addEventListener('resize', fitPresentation);

  function syncVideos() {
    slides.forEach((slide, i) => slide.querySelectorAll('video').forEach(video => {
      const visible = active && i === index && !video.closest('.build-pending');
      const wasVisible = videoVisibility.get(video) === true;
      videoVisibility.set(video, visible);
      if (!visible) {
        video.pause();
      } else if (!wasVisible && (video.getAttribute('src') || video.querySelector('source[src]'))) {
        if (!video.hasAttribute('data-resume')) {
          try { video.currentTime = 0; } catch (_) { /* Media may not have metadata yet. */ }
        }
        const playback = video.play();
        if (playback) playback.then(() => {
          if (!videoVisibility.get(video)) video.pause();
        }).catch(() => { /* Browser autoplay policy can deny playback. */ });
      }
    }));
  }

  function render() {
    slideLinks.forEach((link, i) => link.setAttribute('aria-current', String(i === index)));
    if (active) {
      const totalBuilds = steps[index].length;
      status.textContent = `Slide ${index + 1} of ${slides.length}${totalBuilds ? ` · beat ${Math.min(build, totalBuilds)} of ${totalBuilds}` : ''}`;
    }
    slides.forEach((slide, i) => {
      slide.classList.toggle('present-current', i === index);
      slide.setAttribute('aria-hidden', String(i !== index));
      if (slide.classList.contains('stateful-slide')) slide.dataset.state = String(i === index ? build : steps[i].length);
      slide.querySelectorAll('[data-build]').forEach(el => {
        const step = steps[i].indexOf(Number(el.dataset.build));
        el.classList.toggle('build-pending', step >= build && step !== -1);
      });
    });
    syncVideos();
  }

  function finish() {
    if (!active) return;
    active = false;
    syncVideos();
    document.documentElement.classList.remove('presenting');
    status.textContent = '';
    slides.forEach((slide, i) => {
      slide.classList.remove('present-current');
      slide.removeAttribute('aria-hidden');
      if (slide.classList.contains('stateful-slide')) slide.dataset.state = String(steps[i].length);
      slide.querySelectorAll('.build-pending').forEach(el => el.classList.remove('build-pending'));
    });
    button.focus({ preventScroll: true });
    window.scrollTo(0, scrollY);
  }

  function next() {
    if (build < steps[index].length) build++;
    else if (index < slides.length - 1) { index++; build = 0; }
    render();
  }

  function previous() {
    if (build > 0) build--;
    else if (index > 0) { index--; build = steps[index].length; }
    render();
  }

  button.addEventListener('click', event => {
    event.stopPropagation();
    if (active) return;
    status.textContent = '';
    scrollY = window.scrollY;
    wheelTotal = 0;
    wheelLastAt = -Infinity;
    wheelDirection = 0;
    index = 0;
    build = 0;
    active = true;
    closeNavigation();
    fitPresentation();
    render();
    document.documentElement.classList.add('presenting');
  });

  document.addEventListener('click', event => {
    if (!slideMenu.hidden) { closeNavigation(); return; }
    if (active && event.button === 0) { event.preventDefault(); next(); }
  });
  document.addEventListener('wheel', event => {
    if (!active || event.ctrlKey || Math.abs(event.deltaY) <= Math.abs(event.deltaX)) return;
    const now = performance.now();
    const unit = event.deltaMode === 1 ? 16 : event.deltaMode === 2 ? window.innerHeight : 1;
    const delta = event.deltaY * unit;
    if (Math.abs(delta) < 2) return;
    event.preventDefault();
    const direction = Math.sign(delta);
    // Only accepted beats start the cooldown; reversing bypasses it.
    if (direction === wheelDirection && now - wheelLastAt < wheelCooldownMs) return;
    if (Math.sign(delta) !== Math.sign(wheelTotal)) wheelTotal = 0;
    wheelTotal += delta;
    if (Math.abs(wheelTotal) < 32) return;
    wheelLastAt = now;
    wheelDirection = direction;
    wheelTotal > 0 ? next() : previous();
    wheelTotal = 0;
  }, { passive: false });
  document.addEventListener('keydown', event => {
    if (!active) return;
    if ([' ', 'ArrowRight', 'ArrowDown', 'ArrowLeft', 'ArrowUp', 'Escape'].includes(event.key)) {
      event.preventDefault();
      if (event.repeat) return;
      if (event.key === 'Escape') {
        finish();
      } else if (event.key === 'ArrowLeft' || event.key === 'ArrowUp') previous();
      else next();
    }
  });
})();
