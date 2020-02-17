import Config from "../config";

window.addEventListener("message", event => {
  switch (event.data.action) {
    case "setup":
      console.log(
        "AddEventListener Message resources/mythic_phone/ui/js/src/utils/data.js"
      );
      console.log("event.data");
      console.log(JSON.stringify(event.data));
      console.log("event.data.data");
      console.log(JSON.stringify(event.data.data));
      SetupData(event.data.data);
      break;
    case "Logout":
      ClearData();
      break;
  }
});

function SetupData(data) {
  $.each(data, (index, item) => {
    window.localStorage.setItem(item.name, JSON.stringify(item.data));
  });
}

function StoreData(name, data) {
  window.localStorage.setItem(name, JSON.stringify(data));
}

function AddData(name, value) {
  let arr = GetData(name);
  arr.push(value);
  StoreData(name, arr);
}

function RemoveData(name, index) {
  let arr = GetData(name);
  arr.splice(index, 1);
  StoreData(name, arr);
}

function RemoveObjectData(name, key, value) {
  let arr = GetData(name);
  $.each(arr, (index, item) => {
    if (item[key] == value) {
      RemoveData(name, index);
      return false;
    }
  });
}

function UpdateData(name, index, data) {
  let arr = GetData(name);
  arr[index] = data;
  StoreData(name, arr);
}

function UpdateObjectData(
  name,
  searchKey,
  searchValue,
  updateKey,
  updateValue
) {
  let arr = GetData(name);
  $.each(arr, (index, item) => {
    if (item[searchKey] == searchValue) {
      arr[index][updateKey] = updateValue;
      StoreData(name, arr);
      return false;
    }
  });
}

function GetData(name) {
  console.log("GetData resources/mythic_phone/ui/js/src/utils/data.js");
  console.log(name);
  console.log("JSON.parse(window.localStorage.getItem(name))");
  console.log(JSON.stringify(JSON.parse(window.localStorage.getItem(name))));
  return JSON.parse(window.localStorage.getItem(name));
}

function StoreDataLua(key, data) {
  console.log("StoreDataLua resources/mythic_phone/ui/js/src/utils/data.js");
  console.log("key");
  console.log(JSON.stringify(key));
  console.log("data");
  console.log(JSON.stringify(data));
  $.post(
    Config.ROOT_ADDRESS + "/RegisterData",
    JSON.stringify({
      key: key,
      data: data
    })
  );
}

function GetDataLua(key) {
  console.log("GetDataLua resources/mythic_phone/ui/js/src/utils/data.js");
  console.log("key");
  console.log(JSON.stringify(key));
  $.post(
    Config.ROOT_ADDRESS + "/GetData",
    JSON.stringify({
      key: key
    }),
    data => {
      return data;
    }
  );
}

function ClearData() {
  window.localStorage.clear();
}

export default {
  SetupData,
  StoreData,
  AddData,
  RemoveData,
  RemoveObjectData,
  UpdateData,
  UpdateObjectData,
  GetData,
  ClearData,
  StoreDataLua,
  GetDataLua
};
