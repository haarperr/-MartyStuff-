// Variables
let isGuiOpen = false;
let defaultVehicleValues = [];
let currentVehicle = [];
let ESX = null;

emit("esx:getSharedObject", (obj) => ESX = obj);

RegisterCommand("tuner", () => {
  emit("xgc-tuner:openTuner")
});

RegisterNetEvent("xgc-tuner:openTuner")
AddEventHandler("xgc-tuner:openTuner", () => {
  if (isGuiOpen) return;
  let ped = GetPlayerPed(-1);
  let vehicle = GetVehiclePedIsUsing(ped);
  // Lets check if they're the driver
  if (GetPedInVehicleSeat(vehicle, -1) === ped) {
    let vehiclePlate = GetVehicleNumberPlateText(vehicle);
    let alreadyExist = defaultVehicleValues.findIndex(e => e.plate === vehiclePlate);
    if (alreadyExist < 0) {
      currentVehicle.push({ plate: vehiclePlate, boost: 0, acceleration: 0, gearchange: 0, braking: 5, drivetrain: 5 });
      defaultVehicleValues.push({
        plate: vehiclePlate,
        fInitialDriveForce: GetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDriveForce"),
        fClutchChangeRateScaleUpShift: GetVehicleHandlingFloat(vehicle, "CHandlingData", "fClutchChangeRateScaleUpShift"),
        fClutchChangeRateScaleDownShift: GetVehicleHandlingFloat(vehicle, "CHandlingData", "fClutchChangeRateScaleDownShift"),
        fBrakeBiasFront: GetVehicleHandlingFloat(vehicle, "CHandlingData", "fBrakeBiasFront"),
        fDriveBiasFront: GetVehicleHandlingFloat(vehicle, "CHandlingData", "fDriveBiasFront"),
        fInitialDragCoeff: GetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDragCoeff"),
        fLowSpeedTractionLossMult: GetVehicleHandlingFloat(vehicle, "CHandlingData", "fLowSpeedTractionLossMult"),
        fDriveInertia: GetVehicleHandlingFloat(vehicle, "CHandlingData", "fDriveInertia"),
      });
    }
    let tuneSettings = currentVehicle.find(e => e.plate === vehiclePlate);
    openTunerHud(tuneSettings)
  }
});

function openTunerHud(data) {
  isGuiOpen = true;
  SetNuiFocus(true, true);
  SendNuiMessage(JSON.stringify({ type: "tunerchip-ui", display: true, tune: JSON.stringify(data) }));
}

function applyTune(data) {
  let vehicle = GetVehiclePedIsUsing(GetPlayerPed(-1));
  let index = defaultVehicleValues.findIndex(e => e.plate === data.plate);
  let index2 = currentVehicle.findIndex(e => e.plate === data.plate);

  currentVehicle[index2].boost = data.boost;
  currentVehicle[index2].acceleration = data.acceleration;
  currentVehicle[index2].gearchange = data.gearchange;
  currentVehicle[index2].braking = data.braking;
  currentVehicle[index2].drivetrain = data.drivetrain;

  if (data.boost === 0) {
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDriveForce", defaultVehicleValues[index].fInitialDriveForce);
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fLowSpeedTractionLossMult", defaultVehicleValues[index].fLowSpeedTractionLossMult);
  } else {
    let defaultDriveForce = defaultVehicleValues[index].fInitialDriveForce;
    let defaultTractionLoss = defaultVehicleValues[index].fLowSpeedTractionLossMult;
    let newBoost = defaultDriveForce + defaultDriveForce * (data.boost / 200);
    let newLoss = defaultTractionLoss + defaultTractionLoss * (data.boost / 20);
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDriveForce", newBoost);
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fLowSpeedTractionLossMult", newLoss);
    console.log("New Boost: " + newBoost);
    console.log("New Traction Loss: " + newLoss);
  }

  if (data.boost === 0 && data.acceleration === 0) {
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fDriveInertia", defaultVehicleValues[index].fDriveInertia);
  } else {
    let defInertia = defaultVehicleValues[index].fDriveInertia;
    let newInertia = defInertia + defInertia * (data.boost / 30);
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fDriveInertia", newInertia)
    console.log("New Inertia: " + newInertia);
  }

  if (data.gearchange === 0) {
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fClutchChangeRateScaleUpShift", defaultVehicleValues[index].fClutchChangeRateScaleUpShift)
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fClutchChangeRateScaleDownShift", defaultVehicleValues[index].fClutchChangeRateScaleDownShift)
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDragCoeff", defaultVehicleValues[index].fInitialDragCoeff)
  } else {
    let defScale = defaultVehicleValues[index].fClutchChangeRateScaleUpShift
    let newScale = defScale + data.gearchange;
    let newDrag = (defaultVehicleValues[index].fInitialDragCoeff + (data.gearchange / 45));
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fClutchChangeRateScaleUpShift", newScale)
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fClutchChangeRateScaleDownShift", newScale)
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDragCoeff", newDrag)
    console.log("New gear up/down: " + newScale);
    console.log("New drag: " + newDrag)
  }

  if (data.drivetrain === 5) {
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fDriveBiasFront", defaultVehicleValues[index].fDriveBiasFront)
  } else {
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fDriveBiasFront", (data.drivetrain / 10));
    console.log("New drivetrain: " + (data.drivetrain / 10));
  }

  if (data.braking === 5) {
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fBrakeBiasFront", defaultVehicleValues[index].fBrakeBiasFront);
  } else {
    SetVehicleHandlingFloat(vehicle, "CHandlingData", "fBrakeBiasFront", data.braking / 10);
  }
}

// Close the tuner
function closeGUI() {
  isGuiOpen = false;
  SetNuiFocus(false, false);
  SendNuiMessage(JSON.stringify({ type: "tunerchip-ui", display: false }));
  ESX.UI.Menu.CloseAll() // This is incase you're using default or modified ESX Menu inventory.
}

// Close tuner callback
RegisterNuiCallbackType("closeTuner");
on("__cfx_nui:closeTuner", (data, cb) => {
  closeGUI()
  cb("ok")
});

// Save tune callback
RegisterNuiCallbackType("saveTune");
on("__cfx_nui:saveTune", (data, cb) => {
  applyTune(data);
  closeGUI()
  cb("ok")
});