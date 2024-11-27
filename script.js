const collapse = (ev) => {
  ev.currentTarget.parentElement.querySelectorAll('svg')[0].style.display = 'none';
  ev.currentTarget.parentElement.querySelectorAll('svg')[1].style.display = 'inline';
  ev.currentTarget.parentElement.parentElement.querySelectorAll('div')[1].style.display = 'none';
}

const expand = (ev) => {
  ev.currentTarget.parentElement.querySelectorAll('svg')[0].style.display = 'inline';
  ev.currentTarget.parentElement.querySelectorAll('svg')[1].style.display = 'none';
  ev.currentTarget.parentElement.parentElement.querySelectorAll('div')[1].style.display = 'grid';
}

const changeTab = (ev) => {
  const layout = ev.currentTarget.parentElement.parentElement;
  const allLabels = layout.querySelectorAll('.layout-tab-label');
  const allContents = layout.querySelectorAll('.layout-tab-content');
  const prevIndex = [...allLabels].findIndex(it => it === layout.querySelector(".layout-tab-label.selected"));
  const newIndex = [...allLabels].findIndex(it => it === ev.currentTarget);
  allLabels[prevIndex].classList.remove("selected");
  allContents[prevIndex].style.display = "none";
  allLabels[newIndex].classList.add("selected");
  allContents[newIndex].style.display = "block";
}

const showAside = (ev) => {
  [...document.querySelectorAll(".aside-wrapper")].forEach(a => {
    a.style.zIndex = 1;
  })
  const aside = ev.currentTarget;
  aside.style.zIndex = 2;
}