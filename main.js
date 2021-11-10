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

$(function () {
  $.ajax({
    type: "GET",
    url: "https://5l5r3mxozc.execute-api.ap-northeast-1.amazonaws.com/dev/nike_apig",
    dataType: "json",
  }).then(
    // 取得成功時
    function (json) {},
    function () {
      // エラー発生時
      alert("エラー時に表示されるテキスト");
    }
  );
});
