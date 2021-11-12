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
  $("#submit-task").on("click", function (event) {
    let task = $("#task").val();

    $.ajax({
      type: "POST",
      url: "https://gm0yznl72d.execute-api.ap-northeast-1.amazonaws.com/dev/resource",
      data: { task: task },
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
});
