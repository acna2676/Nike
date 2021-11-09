$(function () {
  $("#image").on("change", function (event) {
    console.log(event);
    var reader = new FileReader();
    reader.onload = function (event) {
      $("#preview").attr("src", event.target.result);
    };
    reader.readAsDataURL(event.target.files[0]);
  });
});
